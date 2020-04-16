# Create boot diagnostic storage account used by VMs
resource "azurerm_storage_account" "bootdiagsa" {
  name                     = "bootdiag${lower(var.geoid)}${format("%06s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.hubspokegw.name
  location                 = azurerm_resource_group.hubspokegw.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}
