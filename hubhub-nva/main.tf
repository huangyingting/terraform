provider "azurerm" {
  version = "~>2.0"
  features {}
}

provider "random" {
  version = "~> 2.2"
}

resource "random_integer" "suffix" {
  min = 0
  max = 999999
}

# Create resource group
resource "azurerm_resource_group" "hubhubnva" {
  name     = "${var.business_unit}-HubHubNVA"
  location = var.location_1
}
