# Create virtual network gateway in hub virtual network
resource "azurerm_public_ip" "hubgw" {
  name                = "GW-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hubgw" {
  name                = "GW-${var.geoid_1}"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid_1}IPConfig"
    public_ip_address_id          = azurerm_public_ip.hubgw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hubgw.id
  }

  bgp_settings {
    asn = 65040
  }
}

resource "azurerm_public_ip" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid_1}IPConfig"
    public_ip_address_id          = azurerm_public_ip.onpremgw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onpremgw.id
  }

  bgp_settings {
    asn = 65030
  }
}

data "azurerm_public_ip" "hubgw" {
  name                = "GW-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.privatelink.name
  depends_on = [azurerm_virtual_network_gateway.hubgw]
}

data "azurerm_public_ip" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.privatelink.name
  depends_on = [azurerm_virtual_network_gateway.onpremgw]
}

resource "azurerm_local_network_gateway" "hublng" {
  name                = "LNG-Hub1-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name
  gateway_address     = data.azurerm_public_ip.hubgw.ip_address
  address_space       = ["${azurerm_virtual_network_gateway.hubgw.bgp_settings[0].peering_address}/32"]
  bgp_settings {
    asn                 = azurerm_virtual_network_gateway.hubgw.bgp_settings[0].asn
    bgp_peering_address = azurerm_virtual_network_gateway.hubgw.bgp_settings[0].peering_address
    peer_weight         = azurerm_virtual_network_gateway.hubgw.bgp_settings[0].peer_weight
  }
  //depends_on = [azurerm_virtual_network_gateway.hubgw]
}

resource "azurerm_local_network_gateway" "onpremlng" {
  name                = "LNG-OnPrem-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name
  gateway_address     = data.azurerm_public_ip.onpremgw.ip_address
  address_space       = ["${azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peering_address}/32"]
  bgp_settings {
    asn                 = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].asn
    bgp_peering_address = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peering_address
    peer_weight         = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peer_weight
  }
  //depends_on = [azurerm_virtual_network_gateway.onpremgw]
}

resource "azurerm_virtual_network_gateway_connection" "hub-to-onprem" {
  name                = "${azurerm_virtual_network_gateway.hubgw.name}-To-${azurerm_virtual_network_gateway.onpremgw.name}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hubgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremlng.id
  shared_key = var.secret
}

resource "azurerm_virtual_network_gateway_connection" "onprem-to-hub" {
  name                = "${azurerm_virtual_network_gateway.onpremgw.name}-To-${azurerm_virtual_network_gateway.hubgw.name}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onpremgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.hublng.id

  shared_key = var.secret
}
