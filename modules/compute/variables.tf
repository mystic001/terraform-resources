variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vm_config" {
  description = "Configuration for the virtual machine"
  type = object({
    name                  = string
    size                  = string
    admin_username       = string
    admin_ssh_public_key = string
    subnet_name          = string
    os_disk_type         = string
    os_disk_size_gb      = number
    image_publisher      = string
    image_offer          = string
    image_sku            = string
    image_version        = string
  })
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "ID of the subnet where the VM will be deployed"
  type        = string
} 