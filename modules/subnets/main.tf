# Public Subnet

module "vpc" {
  source = "../vpc"

  vpc_name = "${var.vpc_name}" # Let's make sure this gets added as a tag
  vpc_cidr = "${var.vpc_cidr}"

  vpc_enable_dns_hostnames    = "${var.vpc_enable_dns_hostnames}"
  vpc_enable_dns_support      = "${var.vpc_enable_dns_support}"
  vpc_create_internet_gateway = "${var.vpc_create_internet_gateway}"

  vpc_tags = {
    Owner       = "${var.candidate_name}"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = "${var.subnets_public_count}"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_block              = "${var.cidrs["public${count.index}"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
}

resource "aws_subnet" "privateapp_subnet" {
  count                   = "${var.subnets_private_count}"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_block              = "${var.cidrs["privateapp${count.index}"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
}

resource "aws_subnet" "privatedb_subnet" {
  count                   = "${var.subnets_private_count}"
  vpc_id                  = "${module.vpc.vpc_id}"
  cidr_block              = "${var.cidrs["privatedb${count.index}"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
}

## Subnet & Route Table Association

resource "aws_route_table_association" "public_assoc" {
  count          = "${var.subnets_public_count}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${module.vpc.public_rt_id}"
}


resource "aws_route_table_association" "privateapp_assoc" {
  count          = "${var.subnets_private_count}"
  subnet_id      = "${aws_subnet.privateapp_subnet.*.id[count.index]}"
  route_table_id = "${module.vpc.default_private_rt_id}"
}

resource "aws_route_table_association" "privatedb_assoc" {
  count          = "${var.subnets_private_count}"
  subnet_id      = "${aws_subnet.privatedb_subnet.*.id[count.index]}"
  route_table_id = "${module.vpc.default_private_rt_id}"
}


## Challanaged faced with use count module  Error got is :   Error loading /home/mitesh/projects/aws/key-me-terraform-proj/infra-exercise/modules/subnets/main.tf: Error reading config for aws_route_table_association[public_assoc]: parse error at 1:40: expected "}" but found "."
## Solved with help of documentation : https://www.terraform.io/docs/configuration-0-11/resources.html

