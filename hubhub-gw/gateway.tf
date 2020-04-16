# Create virtual network gateway in hub virtual network
resource "azurerm_public_ip" "hub1gw" {
  name                = "GW-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub1gw" {
  name                = "GW-${var.geoid_1}"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_1

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid_1}IPConfig"
    public_ip_address_id          = azurerm_public_ip.hub1gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub1gw.id
  }

  bgp_settings {
    asn = 65040
  }
}

resource "azurerm_public_ip" "hub2gw" {
  name                = "GW-${var.geoid_2}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_2
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "hub2gw" {
  name                = "GW-${var.geoid_2}"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_2

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = true
  sku           = "VpnGw1"

  ip_configuration {
    name                          = "GW${var.geoid_2}IPConfig"
    public_ip_address_id          = azurerm_public_ip.hub2gw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub2gw.id
  }

  bgp_settings {
    asn = 65050
  }
}

resource "azurerm_public_ip" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_1
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}"
  resource_group_name = azurerm_resource_group.hubhubgw.name
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

data "azurerm_public_ip" "hub1gw" {
  name                = "GW-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  depends_on = [azurerm_virtual_network_gateway.hub1gw]
}

data "azurerm_public_ip" "hub2gw" {
  name                = "GW-${var.geoid_2}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  depends_on = [azurerm_virtual_network_gateway.hub2gw]
}

data "azurerm_public_ip" "onpremgw" {
  name                = "GW-OnPrem-${var.geoid_1}-PIP"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  depends_on = [azurerm_virtual_network_gateway.onpremgw]  
}

resource "azurerm_local_network_gateway" "hub1lng" {
  name                = "LNG-Hub1-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.hubhubgw.name
  gateway_address     = data.azurerm_public_ip.hub1gw.ip_address
  address_space       = ["${azurerm_virtual_network_gateway.hub1gw.bgp_settings[0].peering_address}/32"]
  bgp_settings {
    asn                 = azurerm_virtual_network_gateway.hub1gw.bgp_settings[0].asn
    bgp_peering_address = azurerm_virtual_network_gateway.hub1gw.bgp_settings[0].peering_address
    peer_weight         = azurerm_virtual_network_gateway.hub1gw.bgp_settings[0].peer_weight
  }
  depends_on = [azurerm_virtual_network_gateway.hub1gw]
}

resource "azurerm_local_network_gateway" "hub2lng" {
  name                = "LNG-Hub2-${var.geoid_2}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.hubhubgw.name
  gateway_address     = data.azurerm_public_ip.hub2gw.ip_address
  address_space       = ["${azurerm_virtual_network_gateway.hub2gw.bgp_settings[0].peering_address}/32"]
  bgp_settings {
    asn                 = azurerm_virtual_network_gateway.hub2gw.bgp_settings[0].asn
    bgp_peering_address = azurerm_virtual_network_gateway.hub2gw.bgp_settings[0].peering_address
    peer_weight         = azurerm_virtual_network_gateway.hub2gw.bgp_settings[0].peer_weight
  }
  depends_on = [azurerm_virtual_network_gateway.hub2gw]
}

resource "azurerm_local_network_gateway" "onpremlng" {
  name                = "LNG-OnPrem-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.hubhubgw.name
  gateway_address     = data.azurerm_public_ip.onpremgw.ip_address
  address_space       = ["${azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peering_address}/32"]
  bgp_settings {
    asn                 = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].asn
    bgp_peering_address = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peering_address
    peer_weight         = azurerm_virtual_network_gateway.onpremgw.bgp_settings[0].peer_weight
  }
  depends_on = [azurerm_virtual_network_gateway.onpremgw]
}

resource "azurerm_virtual_network_gateway_connection" "hub1-to-onprem" {
  name                = "${azurerm_virtual_network_gateway.hub1gw.name}-To-${azurerm_virtual_network_gateway.onpremgw.name}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.hubhubgw.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub1gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremlng.id

  shared_key = var.secret

  depends_on = [azurerm_virtual_network_gateway.hub1gw, azurerm_local_network_gateway.onpremlng]
}

resource "azurerm_virtual_network_gateway_connection" "hub2-to-onprem" {
  name                = "${azurerm_virtual_network_gateway.hub2gw.name}-To-${azurerm_virtual_network_gateway.onpremgw.name}"
  location            = var.location_2
  resource_group_name = azurerm_resource_group.hubhubgw.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.hub2gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onpremlng.id

  shared_key = var.secret
  depends_on = [azurerm_virtual_network_gateway.hub2gw, azurerm_local_network_gateway.onpremlng]
}

resource "azurerm_virtual_network_gateway_connection" "onprem-to-hub1" {
  name                = "${azurerm_virtual_network_gateway.onpremgw.name}-To-${azurerm_virtual_network_gateway.hub1gw.name}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.hubhubgw.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onpremgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub1lng.id

  shared_key = var.secret
  depends_on = [azurerm_virtual_network_gateway.onpremgw, azurerm_local_network_gateway.hub1lng]
}

resource "azurerm_virtual_network_gateway_connection" "onprem-to-hub2" {
  name                = "${azurerm_virtual_network_gateway.onpremgw.name}-To-${azurerm_virtual_network_gateway.hub2gw.name}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.hubhubgw.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.onpremgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.hub2lng.id

  shared_key = var.secret
  depends_on = [azurerm_virtual_network_gateway.onpremgw, azurerm_local_network_gateway.hub2lng]
}
