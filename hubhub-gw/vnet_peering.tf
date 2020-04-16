# Create vnet peerings between hub and spokes
resource "azurerm_virtual_network_peering" "hub1-to-spoke1" {
  name                         = "${azurerm_virtual_network.hub1.name}-To-${azurerm_virtual_network.spoke1.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.hub1.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway.hub1gw, azurerm_virtual_network.spoke1]
}

resource "azurerm_virtual_network_peering" "hub1-to-spoke2" {
  name                         = "${azurerm_virtual_network.hub1.name}-To-${azurerm_virtual_network.spoke2.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.hub1.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway.hub1gw, azurerm_virtual_network.spoke2]
}

resource "azurerm_virtual_network_peering" "spoke1-to-hub1" {
  name                         = "${azurerm_virtual_network.spoke1.name}-To-${azurerm_virtual_network.hub1.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway.hub1gw, azurerm_virtual_network.spoke1]
}


resource "azurerm_virtual_network_peering" "spoke2-to-hub1" {
  name                         = "${azurerm_virtual_network.spoke2.name}-To-${azurerm_virtual_network.hub1.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway.hub1gw, azurerm_virtual_network.spoke2]
}

resource "azurerm_virtual_network_peering" "hub2-to-spoke3" {
  name                         = "${azurerm_virtual_network.hub2.name}-To-${azurerm_virtual_network.spoke3.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.hub2.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke3.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network_gateway.hub2gw, azurerm_virtual_network.spoke3]
}

resource "azurerm_virtual_network_peering" "spoke3-to-hub2" {
  name                         = "${azurerm_virtual_network.spoke3.name}-To-${azurerm_virtual_network.hub2.name}"
  resource_group_name          = azurerm_resource_group.hubhubgw.name
  virtual_network_name         = azurerm_virtual_network.spoke3.name
  remote_virtual_network_id    = azurerm_virtual_network.hub2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
  depends_on                   = [azurerm_virtual_network_gateway.hub2gw, azurerm_virtual_network.spoke3]
}