data "azurerm_subscription" "this" {
}


resource "azurerm_private_link_service" "pls" {
  name                = "Web-pls"
  resource_group_name = azurerm_resource_group.plspenat.name
  location            = azurerm_resource_group.plspenat.location

  auto_approval_subscription_ids              = [data.azurerm_subscription.this.subscription_id]
  visibility_subscription_ids                 = [data.azurerm_subscription.this.subscription_id]
  load_balancer_frontend_ip_configuration_ids = [azurerm_lb.web.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "primary"
    subnet_id                  = azurerm_subnet.pls.id
    primary                    = true
  }

  enable_proxy_protocol = true
}