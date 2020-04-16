# Create hub and spokes virtual networks
resource "azurerm_virtual_network" "hub" {
  name                = "Hub${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokegw.name
  location            = azurerm_resource_group.hubspokegw.location
  address_space       = ["10.8.0.0/16"]
}

resource "azurerm_subnet" "hubgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hubspokegw.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefix       = "10.8.0.0/24"
}

resource "azurerm_virtual_network" "spoke1" {
  name                = "Spoke1${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokegw.name
  location            = azurerm_resource_group.hubspokegw.location
  address_space       = ["10.9.0.0/16"]
}

resource "azurerm_subnet" "spoke1wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubspokegw.name
  virtual_network_name = azurerm_virtual_network.spoke1.name
  address_prefix       = "10.9.0.0/24"
}


resource "azurerm_virtual_network" "spoke2" {
  name                = "Spoke2${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokegw.name
  location            = azurerm_resource_group.hubspokegw.location
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "spoke2wl" {
  name                 = "WLSubnet"
  resource_group_name  = azurerm_resource_group.hubspokegw.name
  virtual_network_name = azurerm_virtual_network.spoke2.name
  address_prefix       = "10.10.0.0/24"
}

# Create virtual network gateway in hub virtual network
resource "azurerm_public_ip" "hubgw" {
  name                = "GW-${var.geoid}-PIP"
  resource_group_name = azurerm_resource_group.hubspokegw.name
  location            = azurerm_resource_group.hubspokegw.location
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hubgw" {
  name                = "GW-${var.geoid}"
  resource_group_name = azurerm_resource_group.hubspokegw.name
  location            = azurerm_resource_group.hubspokegw.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid}IPConfig"
    public_ip_address_id          = azurerm_public_ip.hubgw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hubgw.id
  }
}
