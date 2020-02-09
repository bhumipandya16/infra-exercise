# Public Subnet


resource "aws_subnet" "public_subnet" {
  count                   = "${var.subnets_public_count}"
  vpc_id                  = "${var.subnets_target_vpc_id}"
  cidr_block              = "${var.cidrs["public${count.index}"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${merge(var.subnets_tags, map("Name", format("%s_public${count.index}_subnet", var.vpc_name)))}"
}

resource "aws_subnet" "privateapp_subnet" {
  count                   = "${var.subnets_private_count}"
  vpc_id                  = "${var.subnets_target_vpc_id}"
  cidr_block              = "${var.cidrs["privateapp${count.index}"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${merge(var.subnets_tags, map("Name", format("%s_privateapp${count.index}_subnet", var.vpc_name)))}"
}

resource "aws_subnet" "privatedb_subnet" {
  count                   = "${var.subnets_private_count}"
  vpc_id                  = "${var.subnets_target_vpc_id}"
  cidr_block              = "${var.cidrs["privatedb${count.index}"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${merge(var.subnets_tags, map("Name", format("%s_privatedb${count.index}_subnet", var.vpc_name)))}"

}

## Subnet & Route Table Association

resource "aws_route_table_association" "public_assoc" {
  count          = "${var.subnets_public_count}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.app_public_rt.id}"
}


resource "aws_route_table_association" "privateapp_assoc" {
  count          = "${var.subnets_private_count}"
  subnet_id      = "${aws_subnet.privateapp_subnet.*.id[count.index]}"
  route_table_id = "${aws_default_route_table.app_private_rt.default_route_table_id}"
}

resource "aws_route_table_association" "privatedb_assoc" {
  count          = "${var.subnets_private_count}"
  subnet_id      = "${aws_subnet.privatedb_subnet.*.id[count.index]}"
  route_table_id = "${aws_default_route_table.app_private_rt.default_route_table_id}"
}


# Nat gateway  and update private subnet route table to enable egress traffic to internet

resource "aws_eip" "nat-eip" {
  #count = "${var.subnets_enable_nat_gateway}"
  vpc      = true
}

resource "aws_nat_gateway" "nat-gw" {
  #count = "${var.subnets_enable_nat_gateway}"
  #allocation_id = "${aws_eip.nat-eip.*.id[count.index]}"
  #subnet_id = "${aws_subnet.public_subnet.*.id[count.index]}"

  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id = "${aws_subnet.public_subnet.id}"

  tags = "${merge(var.subnets_tags, map("Name", format("%s_nat_gw", var.vpc_name)))}"
}


## Challanaged faced with use count module  Error got is :   Error loading /home/mitesh/projects/aws/key-me-terraform-proj/infra-exercise/modules/subnets/main.tf: Error reading config for aws_route_table_association[public_assoc]: parse error at 1:40: expected "}" but found "."
## Solved with help of documentation : https://www.terraform.io/docs/configuration-0-11/resources.html

# Route Tables

# Public route table
resource "aws_route_table" "app_public_rt" {
  vpc_id = "${var.subnets_target_vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.subnets_target_vpc_igw_id}"
  }

  tags = "${merge(var.subnets_tags, map("Name", format("%s_public_rt", var.vpc_name)))}"
  
}

# Private Route Table
resource "aws_default_route_table" "app_private_rt" {
  default_route_table_id = "${var.subnets_default_route_table_id}"
 
  route{
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }
  tags = "${merge(var.subnets_tags, map("Name", format("%s_private_rt", var.vpc_name)))}"
  
}