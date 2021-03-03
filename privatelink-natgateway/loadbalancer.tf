resource "azurerm_lb" "web" {
  name                = "Web-lb"
  location            = azurerm_resource_group.plspenat.location
  resource_group_name = azurerm_resource_group.plspenat.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "FE"
    subnet_id            = azurerm_subnet.web.id
    private_ip_address_version      = "IPv4"
  }
}

resource "azurerm_lb_backend_address_pool" "web-pool" {
  loadbalancer_id     = azurerm_lb.web.id
  name                = "web-pool"
}

resource "azurerm_network_interface_backend_address_pool_association" "web" {
  network_interface_id    = azurerm_network_interface.web.id
  ip_configuration_name   = "web-ip-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web-pool.id
}

resource "azurerm_lb_probe" "web" {
  resource_group_name = azurerm_resource_group.plspenat.name
  loadbalancer_id     = azurerm_lb.web.id
  name                = "web-running-probe"
  port                = 80
}

resource "azurerm_lb_rule" "web" {
  resource_group_name            = azurerm_resource_group.plspenat.name
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "web-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "FE"
  probe_id                       = azurerm_lb_probe.web.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web-pool.id
}