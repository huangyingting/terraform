# Create NVA VM in hub virtual network
resource "azurerm_network_interface" "nva_1" {
  name                 = "NVA-${var.geoid_1}"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  location             = var.location_1
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub1nva.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "nva_1" {
  name                            = "NVA-${var.geoid_1}"
  resource_group_name             = azurerm_resource_group.hubhubnva.name
  location                        = var.location_1
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nva_1.id,
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
    storage_account_uri = azurerm_storage_account.bootdiagsa_1.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "nva_1" {
  name                 = "NVAExt-${var.geoid_1}"
  virtual_machine_id   = azurerm_linux_virtual_machine.nva_1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf && sysctl -p"
    }
SETTINGS
}

resource "azurerm_network_interface" "nva_2" {
  name                 = "NVA-${var.geoid_2}"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  location             = var.location_2
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hub2nva.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "nva_2" {
  name                            = "NVA-${var.geoid_2}"
  resource_group_name             = azurerm_resource_group.hubhubnva.name
  location                        = var.location_2
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nva_2.id,
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
    storage_account_uri = azurerm_storage_account.bootdiagsa_2.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_extension" "nva_2" {
  name                 = "NVAExt-${var.geoid_2}"
  virtual_machine_id   = azurerm_linux_virtual_machine.nva_2.id
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

# Spoke 1 routing table
resource "azurerm_route_table" "spoke1" {
  name                = "Spoke1-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.spoke2, azurerm_virtual_network.hub2, azurerm_virtual_network.spoke3, azurerm_network_interface.nva_1]
}

resource "azurerm_route" "spoke1_to_spoke2" {
  count                  = length(azurerm_virtual_network.spoke2.address_space)
  name                   = "To-Spoke2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke1.name
  address_prefix         = azurerm_virtual_network.spoke2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_route" "spoke1_to_hub2" {
  count                  = length(azurerm_virtual_network.hub2.address_space)
  name                   = "To-Hub2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke1.name
  address_prefix         = azurerm_virtual_network.hub2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_route" "spoke1_to_spoke3" {
  count                  = length(azurerm_virtual_network.spoke3.address_space)
  name                   = "To-Spoke3-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke1.name
  address_prefix         = azurerm_virtual_network.spoke3.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1wl.id
  route_table_id = azurerm_route_table.spoke1.id
  depends_on     = [azurerm_subnet.spoke1wl]
}

# Spoke 2 routing table
resource "azurerm_route_table" "spoke2" {
  name                = "Spoke2-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.spoke1, azurerm_virtual_network.hub2, azurerm_virtual_network.spoke3, azurerm_network_interface.nva_1]
}

resource "azurerm_route" "spoke2_to_spoke1" {
  count                  = length(azurerm_virtual_network.spoke1.address_space)
  name                   = "To-Spoke1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke2.name
  address_prefix         = azurerm_virtual_network.spoke1.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_route" "spoke2_to_hub2" {
  count                  = length(azurerm_virtual_network.hub2.address_space)
  name                   = "To-Hub2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke2.name
  address_prefix         = azurerm_virtual_network.hub2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_route" "spoke2_to_spoke3" {
  count                  = length(azurerm_virtual_network.spoke3.address_space)
  name                   = "To-Spoke3-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke2.name
  address_prefix         = azurerm_virtual_network.spoke3.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2wl.id
  route_table_id = azurerm_route_table.spoke2.id
  depends_on     = [azurerm_subnet.spoke2wl]
}

# Spoke 3 routing table
resource "azurerm_route_table" "spoke3" {
  name                = "Spoke3-${var.geoid_2}-RT"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_2
  depends_on          = [azurerm_virtual_network.spoke1, azurerm_virtual_network.hub1, azurerm_virtual_network.spoke2, azurerm_network_interface.nva_2]
}

resource "azurerm_route" "spoke3_to_spoke1" {
  count                  = length(azurerm_virtual_network.spoke1.address_space)
  name                   = "To-Spoke1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke3.name
  address_prefix         = azurerm_virtual_network.spoke1.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_2.private_ip_address
}

resource "azurerm_route" "spoke3_to_hub1" {
  count                  = length(azurerm_virtual_network.hub1.address_space)
  name                   = "To-Hub1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke3.name
  address_prefix         = azurerm_virtual_network.hub1.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_2.private_ip_address
}

resource "azurerm_route" "spoke3_to_spoke2" {
  count                  = length(azurerm_virtual_network.spoke2.address_space)
  name                   = "To-Spoke2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.spoke3.name
  address_prefix         = azurerm_virtual_network.spoke2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_2.private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke3" {
  subnet_id      = azurerm_subnet.spoke3wl.id
  route_table_id = azurerm_route_table.spoke3.id
  depends_on     = [azurerm_subnet.spoke3wl]
}

# Hub 1 routing table
resource "azurerm_route_table" "hub1" {
  name                = "Hub1-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.spoke3, azurerm_network_interface.nva_2]
}

resource "azurerm_route" "hub1_to_spoke3" {
  count                  = length(azurerm_virtual_network.spoke3.address_space)
  name                   = "To-Spoke3-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.hub1.name
  address_prefix         = azurerm_virtual_network.spoke3.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_2.private_ip_address
}

resource "azurerm_subnet_route_table_association" "hub1" {
  subnet_id      = azurerm_subnet.hub1nva.id
  route_table_id = azurerm_route_table.hub1.id
  depends_on     = [azurerm_subnet.hub1nva]
}

# Hub 2 routing table
resource "azurerm_route_table" "hub2" {
  name                = "Hub2-${var.geoid_2}-RT"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_2
  depends_on          = [azurerm_virtual_network.spoke1, azurerm_virtual_network.spoke1, azurerm_network_interface.nva_1]
}

resource "azurerm_route" "hub2_to_spoke1" {
  count                  = length(azurerm_virtual_network.spoke1.address_space)
  name                   = "To-Spoke1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.hub2.name
  address_prefix         = azurerm_virtual_network.spoke1.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_route" "hub2_to_spoke2" {
  count                  = length(azurerm_virtual_network.spoke2.address_space)
  name                   = "To-Spoke2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubnva.name
  route_table_name       = azurerm_route_table.hub2.name
  address_prefix         = azurerm_virtual_network.spoke2.address_space[count.index]
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nva_1.private_ip_address
}

resource "azurerm_subnet_route_table_association" "hub2" {
  subnet_id      = azurerm_subnet.hub2nva.id
  route_table_id = azurerm_route_table.hub2.id
  depends_on     = [azurerm_subnet.hub2nva]
}
