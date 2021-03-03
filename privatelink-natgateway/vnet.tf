resource "azurerm_virtual_network" "pls" {
  name                = "PLS-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name
}

resource "azurerm_subnet" "web" {
  name                 = "Web-subnet"
  resource_group_name  = azurerm_resource_group.plspenat.name
  virtual_network_name = azurerm_virtual_network.pls.name
  address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "pls" {
  name                 = "PLS-subnet"
  resource_group_name  = azurerm_resource_group.plspenat.name
  virtual_network_name = azurerm_virtual_network.pls.name
  address_prefixes       = ["10.0.2.0/24"]
  enforce_private_link_service_network_policies = true
}

resource "azurerm_virtual_network" "pe" {
  name                = "PE-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name
}

resource "azurerm_subnet" "ssh" {
  name                 = "SSH-subnet"
  resource_group_name  = azurerm_resource_group.plspenat.name
  virtual_network_name = azurerm_virtual_network.pe.name
  address_prefixes       = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "pe" {
  name                 = "PE-subnet"
  resource_group_name  = azurerm_resource_group.plspenat.name
  virtual_network_name = azurerm_virtual_network.pe.name
  address_prefixes       = ["10.1.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
}