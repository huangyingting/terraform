# Create boot diagnostic storage account used by VMs in hub
resource "azurerm_storage_account" "bootdiagsa_1" {
  name                     = "bootdiag${lower(var.geoid_1)}${format("%08s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.privatelink.name
  location                 = var.location_1
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

# VM1 in hub
resource "azurerm_network_interface" "wl1" {
  name                 = "WL1-${var.geoid_1}"
  resource_group_name  = azurerm_resource_group.privatelink.name
  location             = var.location_1
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.hubwl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "wl1" {
  name                  = "WL1-${var.geoid_1}"
  location              = var.location_1
  resource_group_name   = azurerm_resource_group.privatelink.name
  network_interface_ids = [azurerm_network_interface.wl1.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "WL1OSDisk${random_integer.suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "WL1-${var.geoid_1}"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.bootdiagsa_1.primary_blob_endpoint
  }
}

# Create boot diagnostic storage account used by VMs in spoke1
resource "azurerm_storage_account" "bootdiagsa_2" {
  name                     = "bootdiag${lower(var.geoid_2)}${format("%08s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.privatelink.name
  location                 = var.location_2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

# VMs in spoke1
resource "azurerm_network_interface" "wl2" {
  name                 = "WL2-${var.geoid_2}"
  resource_group_name  = azurerm_resource_group.privatelink.name
  location             = var.location_2
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.spoke1wl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "wl2" {
  name                  = "WL2-${var.geoid_2}"
  location              = var.location_2
  resource_group_name   = azurerm_resource_group.privatelink.name
  network_interface_ids = [azurerm_network_interface.wl2.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "WL2OSDisk${random_integer.suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "WL2-${var.geoid_2}"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.bootdiagsa_2.primary_blob_endpoint
  }
}

# VMs in on-prem
resource "azurerm_network_interface" "wl3" {
  name                 = "WL3-OnPrem-${var.geoid_1}"
  resource_group_name  = azurerm_resource_group.privatelink.name
  location             = var.location_1
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onpremwl.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "wl3" {
  name                  = "WL3-${var.geoid_1}"
  location              = var.location_1
  resource_group_name   = azurerm_resource_group.privatelink.name
  network_interface_ids = [azurerm_network_interface.wl3.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "WL3OSDisk${random_integer.suffix.result}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "WL3-${var.geoid_1}"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.bootdiagsa_1.primary_blob_endpoint
  }
}

