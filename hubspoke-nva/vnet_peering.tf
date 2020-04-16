# Create vnet peerings between hub and spokes
resource "azurerm_virtual_network_peering" "hub-to-spoke1" {
  name                         = "${azurerm_virtual_network.hub.name}-To-${azurerm_virtual_network.spoke1.name}"
  resource_group_name          = azurerm_resource_group.hubspokenva.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke1]
}

resource "azurerm_virtual_network_peering" "hub-to-spoke2" {
  name                         = "${azurerm_virtual_network.hub.name}-To-${azurerm_virtual_network.spoke2.name}"
  resource_group_name          = azurerm_resource_group.hubspokenva.name
  virtual_network_name         = azurerm_virtual_network.hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke2]
}

resource "azurerm_virtual_network_peering" "spoke1-to-hub" {
  name                         = "${azurerm_virtual_network.spoke1.name}-To-${azurerm_virtual_network.hub.name}"
  resource_group_name          = azurerm_resource_group.hubspokenva.name
  virtual_network_name         = azurerm_virtual_network.spoke1.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke1]
}


resource "azurerm_virtual_network_peering" "spoke2-to-hub" {
  name                         = "${azurerm_virtual_network.spoke2.name}-To-${azurerm_virtual_network.hub.name}"
  resource_group_name          = azurerm_resource_group.hubspokenva.name
  virtual_network_name         = azurerm_virtual_network.spoke2.name
  remote_virtual_network_id    = azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  depends_on                   = [azurerm_virtual_network.hub, azurerm_virtual_network.spoke2]
}