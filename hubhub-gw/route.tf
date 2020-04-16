# Create route tables to route traffics to hub
resource "azurerm_route_table" "spoke1" {
  name                = "Spoke1-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.spoke2, azurerm_virtual_network_gateway.hub1gw]
}

resource "azurerm_route" "spoke1" {
  count                  = length(azurerm_virtual_network.spoke2.address_space)
  name                   = "To-Spoke2-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubgw.name
  route_table_name       = azurerm_route_table.spoke1.name
  address_prefix         = azurerm_virtual_network.spoke2.address_space[count.index]
  next_hop_type          = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "spoke1" {
  subnet_id      = azurerm_subnet.spoke1wl.id
  route_table_id = azurerm_route_table.spoke1.id
  depends_on     = [azurerm_subnet.spoke1wl]
}

resource "azurerm_route_table" "spoke2" {
  name                = "Spoke2-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.hubhubgw.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.spoke2, azurerm_virtual_network_gateway.hub1gw]
}

resource "azurerm_route" "spoke2" {
  count                  = length(azurerm_virtual_network.spoke1.address_space)
  name                   = "To-Spoke1-${count.index}"
  resource_group_name    = azurerm_resource_group.hubhubgw.name
  route_table_name       = azurerm_route_table.spoke2.name
  address_prefix         = azurerm_virtual_network.spoke1.address_space[count.index]
  next_hop_type          = "VirtualNetworkGateway"
}

resource "azurerm_subnet_route_table_association" "spoke2" {
  subnet_id      = azurerm_subnet.spoke2wl.id
  route_table_id = azurerm_route_table.spoke2.id
  depends_on     = [azurerm_subnet.spoke2wl]
}