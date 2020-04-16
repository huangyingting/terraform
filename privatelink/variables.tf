variable "business_unit" {
  description = "The prefix used for all resources in this example"
}

variable "location_1" {
  description = "The Azure location where all resources in this example should be created"
  default     = "southeastasia"
}

variable "geoid_1" {
  description = "GEO Id"
  default     = "SEA"
}

variable "location_2" {
  description = "The Azure location where all resources in this example should be created"
  default     = "southeastasia"
}

variable "geoid_2" {
  description = "GEO Id"
  default     = "SEA"
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
  description = "VPN shared secret"
  default     = "AzureP@ssw0rd"
}
