resource "azurerm_public_ip" "this" {
  name                = "${var.vm_config.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                = "Standard"
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.vm_config.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_config.name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_config.size
  admin_username      = var.vm_config.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  admin_ssh_key {
    username   = var.vm_config.admin_username
    public_key = var.vm_config.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_config.os_disk_type
    disk_size_gb         = var.vm_config.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_config.image_publisher
    offer     = var.vm_config.image_offer
    sku       = var.vm_config.image_sku
    version   = var.vm_config.image_version
  }

  tags = var.tags
} 