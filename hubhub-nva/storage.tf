# Create boot diagnostic storage account used by VMs
resource "azurerm_storage_account" "bootdiagsa_1" {
  name                     = "bootdiag${lower(var.geoid_1)}${format("%06s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.hubhubnva.name
  location                 = var.location_1
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}

# Create boot diagnostic storage account used by VMs
resource "azurerm_storage_account" "bootdiagsa_2" {
  name                     = "bootdiag${lower(var.geoid_2)}${format("%06s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.hubhubnva.name
  location                 = var.location_2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}
