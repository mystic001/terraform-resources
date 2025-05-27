terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstate6862"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  use_cli         = false
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}


# Create main resource group for your resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Generate SSH key
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store the private key in Azure Key Vault (optional but recommended)
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = tls_private_key.ssh.private_key_pem
  key_vault_id = azurerm_key_vault.main.id
}

# Store the public key in Azure Key Vault (optional but recommended)
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key"
  value        = tls_private_key.ssh.public_key_openssh
  key_vault_id = azurerm_key_vault.main.id
}

# Create Key Vault
resource "azurerm_key_vault" "main" {
  name                        = "kv-${var.environment}-${random_string.suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  sku_name                    = "premium"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.key_vault_allowed_ips
  }

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.client_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Import",
      "Backup",
      "Restore",
      "Recover",
      "Purge"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Backup",
      "Restore",
      "Recover",
      "Purge"
    ]

    certificate_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Import",
      "Backup",
      "Restore",
      "Recover",
      "Purge"
    ]
  }
}

# Generate random suffix for unique names
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Add your Azure resources here 

module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  subnets = [
    {
      name             = "firstsubnet"
      address_prefixes = ["10.100.1.0/24"]
    },
    {
      name             = "secondsubnet"
      address_prefixes = ["10.100.2.0/24"]
    },
    {
      name             = "thirdsubnet"
      address_prefixes = ["10.100.3.0/24"]
    }
  ]
}


module "vm" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_ids["firstsubnet"]

  vm_config = {
    name                 = "my-vm"
    size                 = "Standard_B1s"
    admin_username       = "adminuser"
    admin_ssh_public_key = tls_private_key.ssh.public_key_openssh
    subnet_name          = "firstsubnet"
    os_disk_type         = "Standard_LRS"
    os_disk_size_gb      = 30
    image_publisher      = "Canonical"
    image_offer          = "UbuntuServer"
    image_sku            = "18.04-LTS"
    image_version        = "latest"
  }

  tags = var.tags
}

# Data source to retrieve the SSH key from Key Vault
data "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  key_vault_id = azurerm_key_vault.main.id
  depends_on   = [azurerm_key_vault_secret.ssh_private_key]
}

# Output the private key (be careful with this in production)
output "private_key" {
  value     = data.azurerm_key_vault_secret.ssh_private_key.value
  sensitive = true
}

# Output the public key
output "public_key" {
  value = tls_private_key.ssh.public_key_openssh
}

# Output the VM connection information
output "vm_connection_info" {
  description = "Information to connect to the VM"
  value = {
    username = "adminuser"
    host     = module.vm.vm_private_ip
    command  = "ssh -i <private_key_file> adminuser@${module.vm.vm_private_ip}"
  }
  sensitive = true
}