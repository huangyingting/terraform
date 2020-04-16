resource "azurerm_public_ip" "onpremgw_1" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP-1"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_public_ip" "onpremgw_2" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP-2"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_1

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid_1}IPConfig-1"
    public_ip_address_id          = azurerm_public_ip.onpremgw_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onpremgw.id
  }

  ip_configuration {
    name                          = "GW${var.geoid_1}IPConfig-2"
    public_ip_address_id          = azurerm_public_ip.onpremgw_2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onpremgw.id
  }  

  bgp_settings {
    asn = 65030
  }
}