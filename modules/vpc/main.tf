#################################################
# Main VPC
#################################################
resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr}"

    enable_dns_hostnames = "${var.vpc_enable_dns_hostnames}"
    enable_dns_support   = "${var.vpc_enable_dns_support}"

    tags = "${merge(var.vpc_tags, map("Name", format("%s", var.vpc_name)))}"
}

#################################################
# Internet Gateway
#################################################
resource "aws_internet_gateway" "main" {
    count  = "${var.vpc_create_internet_gateway}"
    vpc_id = "${aws_vpc.main.id}"

    tags = "${merge(var.vpc_tags, map("Name", format("%s", var.vpc_name)))}"
}
