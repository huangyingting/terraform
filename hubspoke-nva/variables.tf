variable "business_unit" {
  description = "The prefix used for all resources in this example"
}

variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "southeastasia"
}

variable "geoid" {
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
