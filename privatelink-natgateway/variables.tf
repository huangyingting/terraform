variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "southeastasia"
}

variable "username" {
  description = "Username"
}

variable "password" {
  description = "Password"
}

variable "vm_size" {
  description = "VM size"
  default     = "Standard_B1s"
}

variable "enable_proxy_protocol" {
  description = "Enable proxy protocol"
  default = false
}