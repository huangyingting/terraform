# Create hub and spokes virtual networks
resource "azurerm_virtual_network" "hub" {
  name                = "Hub${var.geoid_1}"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "hubgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.8.0.0/24"
}

resource "azurerm_subnet" "hubfirewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.8.1.0/24"
}

resource "azurerm_subnet" "hubpe" {
  name                                           = "PESubnet"
  resource_group_name                            = azurerm_resource_group.privatelink.name
  virtual_network_name                           = azurerm_virtual_network.hub.name
  address_prefix                                 = "10.8.2.0/24"
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "hubwl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.8.3.0/24"
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "Spoke1${var.geoid_2}"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_2
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "spoke1wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.9.0.0/24"
}

resource "azurerm_virtual_network" "onprem" {
  name                = "OnPrem${var.geoid_1}"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1
  address_space       = ["10.128.0.0/16"]
}

resource "azurerm_subnet" "onpremgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefix       = "10.128.1.0/24"
}

resource "azurerm_subnet" "onpremwl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.privatelink.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefix       = "10.128.0.0/24"
}