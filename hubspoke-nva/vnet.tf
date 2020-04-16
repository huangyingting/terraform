# Create hub and spokes virtual networks
resource "azurerm_virtual_network" "hub" {
  name                = "Hub${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokenva.name
  location            = azurerm_resource_group.hubspokenva.location
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "hubnva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.hubspokenva.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.8.0.0/24"
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "Spoke1${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokenva.name
  location            = azurerm_resource_group.hubspokenva.location
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "spoke1wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubspokenva.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.9.0.0/24"
}


resource "azurerm_virtual_network" "spoke2" {
  name                = "Spoke2${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokenva.name
  location            = azurerm_resource_group.hubspokenva.location
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "spoke2wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubspokenva.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefix       = "10.10.0.0/24"
}
