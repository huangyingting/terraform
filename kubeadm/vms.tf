#kubeadm config print init-defaults --component-configs KubeProxyConfiguration,KubeletConfiguration

data "azurerm_client_config" "this" {
}

data "azurerm_subscription" "this" {
}

locals {
    azure_json = <<EOT
{
    "cloud":"AzurePublicCloud",
    "tenantId": "${data.azurerm_client_config.this.tenant_id}",
    "subscriptionId": "${data.azurerm_subscription.this.subscription_id}",
    "aadClientId": "${var.aad_client_id}",
    "aadClientSecret": "${var.aad_client_secret}",
    "resourceGroup": "${azurerm_resource_group.rg.name}",
    "location": "${var.location}",
    "vmType": "standard",
    "subnetName": "${azurerm_subnet.subnet.name}",
    "securityGroupName": "${azurerm_network_security_group.nsg.name}",
    "vnetName": "${azurerm_virtual_network.vnet.name}",
    "vnetResourceGroup": "${azurerm_resource_group.rg.name}",
    "routeTableName": "${azurerm_route_table.rt.name}",
    "cloudProviderBackoff": true,
    "cloudProviderBackoffRetries": 6,
    "cloudProviderBackoffExponent": 1.5,
    "cloudProviderBackoffDuration": 5,
    "cloudProviderBackoffJitter": 1,
    "cloudProviderRatelimit": true,
    "cloudProviderRateLimitQPS": 3,
    "cloudProviderRateLimitBucket": 10,
    "useManagedIdentityExtension": false,
    "useInstanceMetadata": true,
    "loadBalancerSku": "standard",
    "excludeMasterFromStandardLB": false 
}
EOT

kubeadm_master = <<EOT
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: REPLACE_ME
  bindPort: 6443
nodeRegistration:
  kubeletExtraArgs:
    cloud-config: /etc/kubernetes/azure.json
    cloud-provider: azure
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: ${var.business_unit}
apiServer:
  certSANs:
  - ${lower(var.business_unit)}
  - ${lower(var.business_unit)}.${var.domain}
  - ${azurerm_public_ip.pip.fqdn}
  extraArgs:
    cloud-config: /etc/kubernetes/azure.json
    cloud-provider: azure
  extraVolumes:
  - hostPath: /etc/kubernetes/azure.json
    mountPath: /etc/kubernetes/azure.json
    name: cloud
certificatesDir: /etc/kubernetes/pki
controllerManager:
  extraArgs:
    cloud-config: /etc/kubernetes/azure.json
    cloud-provider: azure
  extraVolumes:
  - hostPath: /etc/kubernetes/azure.json
    mountPath: /etc/kubernetes/azure.json
    name: cloud    
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
networking:
  dnsDomain: cluster.local
  podSubnet: 192.168.0.0/16
  serviceSubnet: 10.96.0.0/12
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
metricsBindAddress: 0.0.0.0
mode: ipvs
EOT

kubeadm_agent = <<EOT
apiVersion: kubeadm.k8s.io/v1beta2
caCertPath: /etc/kubernetes/pki/ca.crt
discovery:
  bootstrapToken:
    apiServerEndpoint: ${lower(var.business_unit)}-00:6443
    token: REPLACE_ME
    unsafeSkipCAVerification: true
  timeout: 5m0s
kind: JoinConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-config: /etc/kubernetes/azure.json
    cloud-provider: azure
EOT

  docker_daemon = <<EOT
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}  
EOT

  custom_data_master  = <<EOT
#cloud-config
runcmd:
  - echo "net.bridge.bridge-nf-call-ip6tables = 1" > /etc/sysctl.d/k8s.conf
  - echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf
  - sysctl --system
  - apt-get install -y apt-transport-https curl ca-certificates gnupg-agent software-properties-common
  - curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  - echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update
  - apt-get install -y kubelet kubeadm kubectl docker-ce docker-ce-cli containerd.io
  - apt-mark hold kubelet kubeadm kubectl
  - apt-get upgrade -y
  - apt-get autoremove -y
  - IP=`ifconfig eth0 | grep 'inet ' | awk '{print $2}'`
  - sed -i "s/REPLACE_ME/$${IP}/g" /etc/kubernetes/kubeadm.yaml
  - kubeadm init --config /etc/kubernetes/kubeadm.yaml
  - mkdir -p /home/${var.username}/.kube
  - cp -i /etc/kubernetes/admin.conf /home/${var.username}/.kube/config
  - chown ${var.username}.${var.username} /home/${var.username}/.kube/config
write_files:
  - path: /etc/kubernetes/azure.json
    encoding: b64
    content: ${base64encode(local.azure_json)}
  - path: /etc/kubernetes/kubeadm.yaml
    encoding: b64
    content: ${base64encode(local.kubeadm_master)}
  - path: /etc/docker/daemon.json
    encoding: b64
    content: ${base64encode(local.docker_daemon)}
  - path: /home/${var.username}/.ssh/id_rsa
    owner: ${var.username}.${var.username}
    permissions: '0400'
    encoding: b64
    content: ${base64encode(file(var.private_key))}
EOT

  custom_data_agent  = <<EOT
#cloud-config
runcmd:
  - echo "net.bridge.bridge-nf-call-ip6tables = 1" > /etc/sysctl.d/k8s.conf
  - echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.d/k8s.conf
  - sysctl --system
  - apt-get install -y apt-transport-https curl ca-certificates gnupg-agent software-properties-common
  - curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  - echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  - add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  - apt-get update
  - apt-get install -y kubelet kubeadm kubectl docker-ce docker-ce-cli containerd.io
  - apt-mark hold kubelet kubeadm kubectl
  - apt-get upgrade -y
  - apt-get autoremove -y
  - mkdir -p /etc/systemd/system/docker.service.d
  - systemctl daemon-reload
  - systemctl restart docker
write_files:
  - path: /etc/kubernetes/azure.json
    encoding: b64
    content: ${base64encode(local.azure_json)}
  - path: /etc/kubernetes/kubeadm.yaml
    encoding: b64
    content: ${base64encode(local.kubeadm_agent)}
  - path: /etc/docker/daemon.json
    encoding: b64
    content: ${base64encode(local.docker_daemon)}
EOT
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.business_unit}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
  domain_name_label   = "${lower(var.business_unit)}${format("%04s", random_integer.id.result)}"
}

resource "azurerm_network_interface" "nics" {
  count                = var.total
  name                 = "${var.business_unit}-${format("%02s", count.index)}-nic"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = count.index == 0 ? azurerm_public_ip.pip.id : ""
  }
}

resource "azurerm_managed_disk" "disks" {
  count                = var.total
  name                 = "Data-${format("%02s", count.index)}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  zones = var.has_zone ? [count.index % 3 + 1] : null
}

resource "azurerm_linux_virtual_machine" "vms" {
  count               = var.total
  name                = "${var.business_unit}-${format("%02s", count.index)}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  zone                = var.has_zone ? count.index % 3 + 1 : null
  admin_username      = var.username
  admin_ssh_key {
    username   = var.username
    public_key = file(var.public_key)
  }

  disable_password_authentication = true
  network_interface_ids = [
    azurerm_network_interface.nics[count.index].id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  custom_data = count.index == 0 ? base64encode(local.custom_data_master) : base64encode(local.custom_data_agent)
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiagsa.primary_blob_endpoint
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "vmdda" {
  count              = var.total
  managed_disk_id    = azurerm_managed_disk.disks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vms[count.index].id
  caching            = "None"
  lun                = "0"
}