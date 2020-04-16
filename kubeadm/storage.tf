resource "azurerm_storage_account" "bootdiagsa" {
  name                     = "bootdiag${lower(var.business_unit)}${format("%04s", random_integer.id.result)}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}
