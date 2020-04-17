output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "help_msg" {
  value = <<EOT
master: kubeadm init --config /etc/kubernetes/kubeadm.yaml
agent: kubeadm join --config /etc/kubernetes/kubeadm.yaml
EOT
}