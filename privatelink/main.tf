provider "azurerm" {
  version = "=1.44.0"
}

provider "random" {
  version = "=2.2.1"
}

resource "random_integer" "suffix" {
  min = 0
  max = 99999999
}

# Create resource group
resource "azurerm_resource_group" "privatelink" {
  name     = "${var.business_unit}-PrivateLink"
  location = var.location_1
}
