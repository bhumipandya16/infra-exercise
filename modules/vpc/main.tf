#################################################
# Main VPC
#################################################
resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"

    enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"
    enable_dns_support   = "${var.vpc_enable_dns_support}"

    tags = "${merge(var.vpc_tags, map("Name", format("%s_vpc", var.vpc_name)))}"
}

#################################################
# Internet Gateway
#################################################
resource "aws_internet_gateway" "main" {
    count  = "${var.vpc_create_internet_gateway}"
    vpc_id = "${aws_vpc.main.id}"

    tags = "${merge(var.vpc_tags, map("Name", format("%s_igw", var.vpc_name)))}"
}

# Route Tables

# Public route table
resource "aws_route_table" "app_public_rt" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = "${merge(var.vpc_tags, map("Name", format("%s_public_rt", var.vpc_name)))}"
  
}

# Private Route Table
resource "aws_default_route_table" "app_private_rt" {
  default_route_table_id = "${aws_vpc.main.default_route_table_id}"
 
  tags = "${merge(var.vpc_tags, map("Name", format("%s_private_rt", var.vpc_name)))}"
  
}