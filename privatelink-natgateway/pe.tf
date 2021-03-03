resource "azurerm_private_endpoint" "pe" {
  name                = "Web-pe"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name
  subnet_id           = azurerm_subnet.pe.id

  private_service_connection {
    name                           = "web-plsconnection"
    private_connection_resource_id = azurerm_private_link_service.pls.id
    is_manual_connection           = false
  }
}