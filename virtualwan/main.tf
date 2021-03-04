terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }    
  }
}

provider "azurerm" {
  features {}
}

provider "random" {
}

resource "random_integer" "suffix" {
  min = 0
  max = 9999
}

# Create resource group
resource "azurerm_resource_group" "virtualwan" {
  name     = "vWAN-${format("%04s", random_integer.suffix.result)}"
  location = var.location_1
}