resource "azurerm_frontdoor" "atmafd" {
  name                                         = var.afd_name
  resource_group_name                          = data.azurerm_resource_group.atmafd.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = var.afd_name
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [var.afd_name]
    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = var.afd_name
    }
  }

  backend_pool_load_balancing {
    name = var.afd_name
  }

  backend_pool_health_probe {
    name = var.afd_name
  }

  backend_pool {
    name = var.afd_name
    dynamic "backend" {
      for_each = toset(var.afd_backends)
      content{
        host_header = backend.key
        address     = backend.key
        http_port   = 80
        https_port  = 443
      }
    }

    load_balancing_name = var.afd_name
    health_probe_name   = var.afd_name
  }

  frontend_endpoint {
    name                              = var.afd_name
    host_name                         = "${var.afd_name}.azurefd.net"
  }
}