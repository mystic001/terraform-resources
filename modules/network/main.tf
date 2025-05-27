resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each             = { for subnet in var.subnets : subnet.name => subnet }
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
}

# Create Network Security Group
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.vnet_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create NSG rule for SSH
resource "azurerm_network_security_rule" "ssh" {
  name                        = "allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = { for subnet in var.subnets : subnet.name => subnet }
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this.id
} 