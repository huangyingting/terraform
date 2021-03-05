variable "location" {
  description = "The Azure location where all resources in this example should be created"
  default     = "southeastasia"
}

variable "afd_name" {
  description = "Azure front door name"
}

variable "afd_backends" {
  description = "Azure front door backends"
  type    = list(string)
}