# Storage account used by private link demo
resource "azurerm_storage_account" "demo" {
  name                     = "demo${lower(var.geoid_1)}${format("%06s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.privatelink.name
  location                 = var.location_1
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_account_network_rules" "demo" {
  resource_group_name  = azurerm_resource_group.privatelink.name
  storage_account_name = azurerm_storage_account.demo.name
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
}

resource "azurerm_private_endpoint" "sademo" {
  name                = "${azurerm_storage_account.demo.name}-pe"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name
  subnet_id           = azurerm_subnet.hubpe.id

  private_service_connection {
    name                           = "${azurerm_storage_account.demo.name}-psc"
    private_connection_resource_id = azurerm_storage_account.demo.id
    subresource_names = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sablob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.privatelink.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sablob_hub" {
  name                  = "SABlob-Hub"
  resource_group_name   = azurerm_resource_group.privatelink.name
  private_dns_zone_name = azurerm_private_dns_zone.sablob.name
  virtual_network_id    = azurerm_virtual_network.hub.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "sablob_spoke1" {
  name                  = "SABlob-Spoke1"
  resource_group_name   = azurerm_resource_group.privatelink.name
  private_dns_zone_name = azurerm_private_dns_zone.sablob.name
  virtual_network_id    = azurerm_virtual_network.spoke1.id
}

# Find the IP Address associated with the private endpoint created above
data "azurerm_private_endpoint_connection" "sademo" {
  name                = azurerm_private_endpoint.sademo.name
  resource_group_name = azurerm_resource_group.privatelink.name
  depends_on          = [azurerm_private_endpoint.sademo]
}

resource "azurerm_private_dns_a_record" "sablob_demo" {
  name                = azurerm_storage_account.demo.name
  zone_name           = azurerm_private_dns_zone.sablob.name
  resource_group_name = azurerm_resource_group.privatelink.name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.sademo.private_service_connection.0.private_ip_address]
}
