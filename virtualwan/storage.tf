# Create boot diagnostic storage account used by VMs in location_1
resource "azurerm_storage_account" "bootdiagsa_1" {
  name                     = "bootdiag${lower(var.geoid_1)}${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.virtualwan.name
  location                 = var.location_1
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}

# Create boot diagnostic storage account used by VMs in location_2
resource "azurerm_storage_account" "bootdiagsa_2" {
  name                     = "bootdiag${lower(var.geoid_2)}${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.virtualwan.name
  location                 = var.location_2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}

# Create boot diagnostic storage account used by VMs in location_3
resource "azurerm_storage_account" "bootdiagsa_3" {
  name                     = "bootdiag${lower(var.geoid_3)}${format("%04s", random_integer.suffix.result)}"
  resource_group_name      = azurerm_resource_group.virtualwan.name
  location                 = var.location_3
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "Storage"
}
