resource "azurerm_public_ip" "natgw" {
  name                = "nat-gateway-pip"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "natgw" {
  name                    = "NATGW"
  location                = azurerm_resource_group.plspenat.location
  resource_group_name     = azurerm_resource_group.plspenat.name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_nat_gateway_public_ip_association" "example" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natgw.id
}

resource "azurerm_subnet_nat_gateway_association" "nat" {
  subnet_id      = azurerm_subnet.web.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}