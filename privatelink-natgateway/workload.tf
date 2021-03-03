# Web VM, private link provider
resource "azurerm_storage_account" "web" {
  name                     = "webbootdiagsa${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.plspenat.name
  location                 = azurerm_resource_group.plspenat.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_network_interface" "web" {
  name                = "Web-nic"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name

  ip_configuration {
    name                          = "web-ip-config"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                = "Web"
  resource_group_name = azurerm_resource_group.plspenat.name
  location            = azurerm_resource_group.plspenat.location
  size                = var.vm_size
  disable_password_authentication  = false  
  admin_username                  = var.username
  admin_password                  = var.password
  network_interface_ids = [
    azurerm_network_interface.web.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.web.primary_blob_endpoint
  }  
  custom_data = filebase64("cloud-init.yaml")
}

# Client VM, private link provider
resource "azurerm_storage_account" "client" {
  name                     = "clientbootdiagsa${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.plspenat.name
  location                 = azurerm_resource_group.plspenat.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_network_interface" "client" {
  name                = "Client-nic"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name

  ip_configuration {
    name                          = "client-ip-config"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "Client" {
  name                = "Client"
  resource_group_name = azurerm_resource_group.plspenat.name
  location            = azurerm_resource_group.plspenat.location
  size                = var.vm_size
  disable_password_authentication  = false  
  admin_username                  = var.username
  admin_password                  = var.password
  network_interface_ids = [
    azurerm_network_interface.client.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.client.primary_blob_endpoint
  }  
}

# SSH VM

resource "azurerm_storage_account" "ssh" {
  name                     = "sshbootdiagsa${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.plspenat.name
  location                 = azurerm_resource_group.plspenat.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_network_interface" "ssh" {
  name                = "SSH-nic"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name

  ip_configuration {
    name                          = "ssh-ip-config"
    subnet_id                     = azurerm_subnet.ssh.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "ssh" {
  name                = "SSH"
  resource_group_name = azurerm_resource_group.plspenat.name
  location            = azurerm_resource_group.plspenat.location
  size                = var.vm_size
  disable_password_authentication  = false
  admin_username                  = var.username
  admin_password                  = var.password
  network_interface_ids = [
    azurerm_network_interface.ssh.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.ssh.primary_blob_endpoint
  } 

}
