provider "azurerm" {
  version = "=2.0.0"
  features {}
}

provider "random" {
  version = "~> 2.2"
}

resource "random_integer" "suffix" {
  min = 0
  max = 999999
  keepers = {
    business_unit = var.business_unit
  }
}

# Create resource group
resource "azurerm_resource_group" "hubhubgw" {
  name     = "${var.business_unit}-HubHubGW"
  location = var.location_1
}
