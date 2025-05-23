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
    # client_id           = "env:ARM_CLIENT_ID"
    # client_secret       = "env:ARM_CLIENT_SECRET"
    # tenant_id           = "env:ARM_TENANT_ID"
    # subscription_id     = "env:ARM_SUBSCRIPTION_ID"
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

# Generate random string for storage account name
resource "random_string" "storage_account_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create resource group for state storage
resource "azurerm_resource_group" "state" {
  name     = "rg-terraform-state"
  location = var.location
  tags     = var.tags
}

# Create storage account for state file
resource "azurerm_storage_account" "state" {
  name                     = "tfstate${random_string.storage_account_suffix.result}"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Create container for state file
resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.state.name
  container_access_type = "private"
}

# Create main resource group for your resources
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Add your Azure resources here 