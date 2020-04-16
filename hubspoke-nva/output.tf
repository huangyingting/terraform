output "NVA-IP" {
  value = azurerm_network_interface.nva.private_ip_address
}

output "WL1-IP" {
  value = azurerm_network_interface.wl1.private_ip_address
}

output "WL2-IP" {
  value = azurerm_network_interface.wl2.private_ip_address
}