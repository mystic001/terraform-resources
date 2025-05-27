output "vm_id" {
  description = "The ID of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_private_ip" {
  description = "The private IP address of the Virtual Machine"
  value       = azurerm_network_interface.this.private_ip_address
}

output "vm_public_ip" {
  description = "The public IP address of the Virtual Machine"
  value       = azurerm_public_ip.this.ip_address
}

output "vm_connection_info" {
  description = "Information to connect to the VM"
  value = {
    username = var.vm_config.admin_username
    host     = azurerm_public_ip.this.ip_address
    command  = "ssh -i <private_key_file> ${var.vm_config.admin_username}@${azurerm_public_ip.this.ip_address}"
  }
  sensitive = true
} 