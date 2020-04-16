provider "azurerm" {
  version = "~>2.0"
  features {}
}

provider "random" {
  version = "~> 2.2"
}

resource "random_integer" "id" {
  min = 0
  max = 9999
  keepers = {
    business_unit = var.business_unit
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.business_unit
  location = var.location
}
