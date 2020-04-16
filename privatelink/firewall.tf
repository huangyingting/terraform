resource "azurerm_public_ip" "firewall" {
  name                = "FW-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = "FW-${var.geoid_1}"
  location            = var.location_1
  resource_group_name = azurerm_resource_group.privatelink.name

  ip_configuration {
    name                 = "ipconfig1"
    subnet_id            = azurerm_subnet.hubfirewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_application_rule_collection" "firewall" {
  name                = "App-Rules"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.privatelink.name
  priority            = 100
  action              = "Deny"

  rule {
    name = "Deny-Storage-Access"

    source_addresses = [
      "10.0.0.0/8",
    ]

    target_fqdns = [
      "*.blob.core.windows.net",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }    
  }
}

# Spoke 1 routing table
resource "azurerm_route_table" "hubwl" {
  name                = "Hub-${var.geoid_1}-RT"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_1
  depends_on          = [azurerm_virtual_network.hub, azurerm_firewall.firewall]
}

resource "azurerm_route" "hubwl" {
  name                   = "Firewall"
  resource_group_name    = azurerm_resource_group.privatelink.name
  route_table_name       = azurerm_route_table.hubwl.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "hubwl" {
  subnet_id      = azurerm_subnet.hubwl.id
  route_table_id = azurerm_route_table.hubwl.id
  depends_on     = [azurerm_subnet.hubwl]
}

# Spoke 1 routing table
resource "azurerm_route_table" "spoke1wl" {
  name                = "Spoke1-${var.geoid_2}-RT"
  resource_group_name = azurerm_resource_group.privatelink.name
  location            = var.location_2
  depends_on          = [azurerm_virtual_network.spoke1, azurerm_firewall.firewall]
}

resource "azurerm_route" "spoke1wl" {
  name                   = "Firewall"
  resource_group_name    = azurerm_resource_group.privatelink.name
  route_table_name       = azurerm_route_table.spoke1wl.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "spoke1wl" {
  subnet_id      = azurerm_subnet.spoke1wl.id
  route_table_id = azurerm_route_table.spoke1wl.id
  depends_on     = [azurerm_subnet.spoke1wl]
}