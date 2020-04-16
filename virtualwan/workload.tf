# Create test VMs
resource "azurerm_network_interface" "wl1" {
  name                 = "WL1-${var.geoid_1}"
  resource_group_name  = azurerm_resource_group.virtualwan.name
  location             = var.location_1
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke1wl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "wl1" {
  name                            = "WL1-${var.geoid_1}"
  resource_group_name             = azurerm_resource_group.virtualwan.name
  location                        = var.location_1
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.wl1.id,
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

resource "azurerm_network_interface" "wl2" {
  name                 = "WL2-${var.geoid_3}"
  resource_group_name  = azurerm_resource_group.virtualwan.name
  location             = var.location_3
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke2wl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "wl2" {
  name                            = "WL2-${var.geoid_3}"
  resource_group_name             = azurerm_resource_group.virtualwan.name
  location                        = var.location_3
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.wl2.id,
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
    storage_account_uri = azurerm_storage_account.bootdiagsa_3.primary_blob_endpoint
  }
}

resource "azurerm_network_interface" "wl3" {
  name                 = "WL3-${var.geoid_2}"
  resource_group_name  = azurerm_resource_group.virtualwan.name
  location             = var.location_2
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke3wl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "wl3" {
  name                            = "WL3-${var.geoid_2}"
  resource_group_name             = azurerm_resource_group.virtualwan.name
  location                        = var.location_2
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.wl3.id,
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

resource "azurerm_network_interface" "wl4" {
  name                 = "WL4-OnPrem-${var.geoid_1}"
  resource_group_name  = azurerm_resource_group.virtualwan.name
  location             = var.location_1
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onpremwl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "wl4" {
  name                            = "WL4-OnPrem-${var.geoid_1}"
  resource_group_name             = azurerm_resource_group.virtualwan.name
  location                        = var.location_1
  size                            = var.vm_size
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.wl4.id,
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
