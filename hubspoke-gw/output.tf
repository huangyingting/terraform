output "wl1_ip" {
  value = azurerm_network_interface.wl1.private_ip_address
}

output "wl2_ip" {
  value = azurerm_network_interface.wl2.private_ip_address
}
