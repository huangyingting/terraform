resource "azurerm_virtual_wan" "virtualwan" {
  name                           = "vwan"
  resource_group_name            = azurerm_resource_group.virtualwan.name
  location                       = var.location_1
  allow_branch_to_branch_traffic = true
  office365_local_breakout_category = "Optimize"
  disable_vpn_encryption = false
  type = "Standard"
}

resource "azurerm_virtual_hub" "virtualhub_1" {
  name                = "vHub${var.geoid_1}"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_1
  address_prefix      = "10.8.0.0/16"
  virtual_wan_id      = azurerm_virtual_wan.virtualwan.id
}

resource "azurerm_virtual_hub" "virtualhub_2" {
  name                = "vHub${var.geoid_2}"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_2
  address_prefix      = "10.16.0.0/16"
  virtual_wan_id      = azurerm_virtual_wan.virtualwan.id
}

resource "azurerm_virtual_hub_connection" "virtualhub_1_conn_1" {
  name                      = "vHub${var.geoid_1}_Conn_1"
  virtual_hub_id            = azurerm_virtual_hub.virtualhub_1.id
  remote_virtual_network_id = azurerm_virtual_network.spoke1.id
}

resource "azurerm_virtual_hub_connection" "virtualhub_1_conn_2" {
  name                      = "vHub${var.geoid_1}_Conn_2"
  virtual_hub_id            = azurerm_virtual_hub.virtualhub_1.id
  remote_virtual_network_id = azurerm_virtual_network.spoke2.id
}

resource "azurerm_vpn_gateway" "vpng_1" {
  name                = "vHub${var.geoid_1}GW"
  resource_group_name = azurerm_resource_group.virtualwan.name
  location            = var.location_1
  virtual_hub_id      = azurerm_virtual_hub.virtualhub_1.id
  bgp_settings {
    asn         = 65515
    peer_weight = 100
  }
  scale_unit = 1

  depends_on = [ azurerm_virtual_hub_connection.virtualhub_1_conn_1, azurerm_virtual_hub_connection.virtualhub_1_conn_2 ]
}

resource "azurerm_virtual_hub_connection" "virtualhub_2_conn_1" {
  name                      = "vHub${var.geoid_2}_Conn_1"
  virtual_hub_id            = azurerm_virtual_hub.virtualhub_2.id
  remote_virtual_network_id = azurerm_virtual_network.spoke3.id
}
