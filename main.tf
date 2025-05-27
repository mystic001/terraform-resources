terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
  use_cli = false
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

  resource_group_name = "my-rg"
  location           = "eastus"
  subnet_id          = module.network.azurerm_subnet.this["firstsubnet"].id

  vm_config = {
    name                  = "my-vm"
    size                  = "Standard_B1s"
    admin_username       = "adminuser"
    admin_ssh_public_key = file("~/.ssh/id_rsa.pub")  # Path to your public SSH key
    subnet_name          = "firstsubnet"
    os_disk_type         = "Standard_LRS"
    os_disk_size_gb      = 30
    image_publisher      = "Canonical"
    image_offer          = "UbuntuServer"
    image_sku            = "18.04-LTS"
    image_version        = "latest"
  }

  tags = {
    Environment = "Development"
  }
}