# Create NVA VM in hub virtual network
resource "azurerm_network_interface" "nva" {
  name                 = "NVA-${var.geoid}"
  resource_group_name  = azurerm_resource_group.hubspokenva.name
  location             = azurerm_resource_group.hubspokenva.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hubnva.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "nva" {
  name                            = "NVA-${var.geoid}"
  resource_group_name             = azurerm_resource_group.hubspokenva.name
  location                        = azurerm_resource_group.hubspokenva.location
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nva.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiagsa.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "nva" {
  name                 = "NVAExt-${var.geoid}"
  virtual_machine_id   = azurerm_linux_virtual_machine.nva.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf && sysctl -p"
    }
SETTINGS
}

# Create route tables to route traffics to hub
resource "azurerm_route_table" "spoke1" {
  name                = "Spoke1-${var.geoid}-RT"
  resource_group_name = azurerm_resource_group.hubspokenva.name
  location            = azurerm_resource_group.hubspokenva.location
  depends_on          = [azurerm_virtual_network.spoke2, azurerm_network_interface.nva]
}

resource "azurerm_route" "spoke1" {
  count                  = length(azurerm_virtual_network.spoke2.address_space)
  name                   = "To-Spoke2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubspokenva.name
  route_table_name       = azurerm_route_table.spoke1.name
  address_prefix         = azurerm_virtual_network.spoke2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva.private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1wl.id
  route_table_id = azurerm_route_table.spoke1.id
  depends_on     = [azurerm_subnet.spoke1wl]
}

resource "azurerm_route_table" "spoke2" {
  name                = "Spoke2-${var.geoid}-RT"
  resource_group_name = azurerm_resource_group.hubspokenva.name
  location            = azurerm_resource_group.hubspokenva.location
  depends_on          = [azurerm_virtual_network.spoke1, azurerm_network_interface.nva]
}

resource "azurerm_route" "spoke2" {
  count                  = length(azurerm_virtual_network.spoke1.address_space)
  name                   = "To-Spoke1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubspokenva.name
  route_table_name       = azurerm_route_table.spoke2.name
  address_prefix         = azurerm_virtual_network.spoke1.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva.private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2wl.id
  route_table_id = azurerm_route_table.spoke2.id
  depends_on     = [azurerm_subnet.spoke2wl]
}