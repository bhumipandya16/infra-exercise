data "aws_availability_zones" "available" {}

variable "cidrs" {
  type = "map"
}

#################################################
# Variables for setting up subnets and routing
#################################################
variable "subnets_az_state_filter" {
  description = "This value can be used to filter Availability Zones to use when setting up network resources. Let's only use available AZs as *data* sources"
  default     = "available"
}

variable "subnets_private_count" {
  description = "How many private subnets to make."
  default     = 2
}

variable "subnets_public_count" {
  description = "How many public subnets to make. Just 1 is required for a NAT Gateway."
  default     = 1
}

variable "subnets_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

variable "subnets_enable_nat_gateway" {
  description = "A boolean flag to enable/disable the creation of a NAT Gateway."
  default     = true
}


#################################################
# Variables for building out a VPC
#################################################
variable "vpc_name" {
  description = "Name of the VPC. Examples include 'prod', 'dev', 'mgmt', etc."
  default     = "terraform-aws-vpc-hiring"
}

variable "vpc_cidr" {
  description = "The IP address range of the VPC in CIDR notation."
  default     = "10.9.0.0/16"
}

variable "vpc_enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = true
}

variable "vpc_enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = true
}

variable "vpc_create_internet_gateway" {
  description = "A boolean flag to enable/disable the creation of an Internet Gateway"
  default     = true
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  default     = {}
}

## Candidate names

variable "candidate_name" {
  description = "Hey! Thanks for working on this sample project. Let's start with your name."
  default     = "YOUR_NAME"
}

variable "environment" {
  description = "The environment to use for this infrastructure deployment. In this case, we'll juset use 'Test'"
  default     = "Test"
}
