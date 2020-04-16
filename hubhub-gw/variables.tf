variable "business_unit" {
  description = "The prefix used for all resources in this example"
}

variable "location_1" {
  description = "The Azure location where hub 1 resources in this example should be created"
  default     = "southeastasia"
}

variable "geoid_1" {
  description = "GEO Id 1"
  default     = "SEA"
}

variable "location_2" {
  description = "The Azure location where hub 2 resources in this example should be created"
  default     = "eastasia"
}

variable "geoid_2" {
  description = "GEO Id 2"
  default     = "EA"
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

variable "secret" {
  description = "VPN connection secret"
  default     = "AzureP@ssw0rd"
}
