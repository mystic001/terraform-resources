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
  value       = azurerm_network_interface.this.private_ip_address
} 