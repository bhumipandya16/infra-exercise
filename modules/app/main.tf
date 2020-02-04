#Security groups
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


module "subnets" {
    source = "../../modules/subnets"

    subnets_target_vpc_id      = "${module.vpc.vpc_id}"
    subnets_target_vpc_igw_id  = "${module.vpc.vpc_igw_id}"
    public_route_table_id = "${module.vpc.public_rt_id}"
    default_rotue_table_id = "${module.vpc.default_private_rt_id}"
    cidrs = "${var.cidrs}"
    subnets_az_state_filter    = "${var.subnets_az_state_filter}"
    subnets_private_count      = "${var.subnets_private_count}"  # Let's make sure to use distinct AZs for each
    subnets_public_count       = "${var.subnets_public_count}"
    subnets_enable_nat_gateway = "${var.subnets_enable_nat_gateway}"

    subnets_tags = {
        Owner       = "${var.candidate_name}"
        Environment = "${var.environment}"
    }
}

#Security groups

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Used for access to the app instance"
  vpc_id      = "${module.vpc.vpc_id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

