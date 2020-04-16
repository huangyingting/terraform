# Create hub and spokes virtual networks
resource "azurerm_virtual_network" "hub1" {
  name                = "Hub1${var.geoid_1}"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "hub1nva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  virtual_network_name = azurerm_virtual_network.hub1.name
  address_prefix       = "10.8.0.0/24"
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "Spoke1${var.geoid_1}"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "spoke1wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.9.0.0/24"
}


resource "azurerm_virtual_network" "spoke2" {
  name                = "Spoke2${var.geoid_1}"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_1
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "spoke2wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefix       = "10.10.0.0/24"
}

resource "azurerm_virtual_network" "hub2" {
  name                = "Hub2${var.geoid_2}"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_2
  address_space       = ["10.16.0.0/16"]
}

resource "azurerm_subnet" "hub2nva" {
  name                 = "NVASubnet"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  virtual_network_name = azurerm_virtual_network.hub2.name
  address_prefix       = "10.16.0.0/24"
}

resource "azurerm_virtual_network" "spoke3" {
  name                = "Spoke3${var.geoid_2}"
  resource_group_name = azurerm_resource_group.hubhubnva.name
  location            = var.location_2
  address_space       = ["10.17.0.0/16"]
}

resource "azurerm_subnet" "spoke3wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubhubnva.name
  virtual_network_name = azurerm_virtual_network.spoke3.name
  address_prefix       = "10.17.0.0/24"
}
