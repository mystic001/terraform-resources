variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default = "rg-group"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "client_id" {
  description = "The Client ID for the Service Principal"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "The Client Secret for the Service Principal"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The Tenant ID for the Service Principal"
  type        = string
}

variable "subscription_id" {
  description = "The Subscription ID for the Service Principal"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
  sensitive   = true
} 