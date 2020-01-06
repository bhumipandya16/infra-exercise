# VPC Module Input Varialbles

variable "vpc_name" {
    description = "Name of the VPC. Examples include 'prod', 'dev', 'mgmt', etc."
}

variable "vpc_cidr" {
    description = "The IP address range of the VPC in CIDR notation. A prefix of /18 is recommended. Do not use a prefix higher than /27. Examples include '10.100.0.0/18', '10.200.0.0/18', etc."
}

variable "vpc_enable_dns_hostnames" {
    description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
}

variable "vpc_enable_dns_support" {
    description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
}

variable "vpc_create_internet_gateway" {
    description = "A boolean flag to enable/disable the creation of an Internet Gateway"
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}