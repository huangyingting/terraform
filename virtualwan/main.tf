provider "azurerm" {
  version = "=2.7.0"
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
resource "azurerm_resource_group" "virtualwan" {
  name     = "${var.business_unit}-vWAN"
  location = var.location_1
}
