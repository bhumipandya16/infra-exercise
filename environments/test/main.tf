
# NOTE: Setting a required version to help with compatibility
terraform {
    required_version = ">= 0.10.8"
}

# Configure the AWS Provider
provider "aws" {
    version = "~> 1.9"
    profile = "keyme-test"
    region  = "us-east-1"
}

module "vpc" {
    source = "../../modules/vpc"

    vpc_name = "${var.vpc_name}"  # Let's make sure this gets added as a tag
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
    vpc_name = "${var.vpc_name}"
    subnets_target_vpc_id      = "${module.vpc.vpc_id}"
    subnets_target_vpc_igw_id  = "${module.vpc.vpc_igw_id}"
    subnets_az_state_filter    = "${var.subnets_az_state_filter}"
    subnets_private_count      = "${var.subnets_private_count}"  # Let's make sure to use distinct AZs for each
    subnets_public_count       = "${var.subnets_public_count}"
    subnets_enable_nat_gateway = "${var.subnets_enable_nat_gateway}"

    subnets_default_route_table_id = "${module.vpc.default_route_table_id}"
    # Todo make it dynamic based on vpc cidr and based on number of subnets Added contant cidr blocks
    cidrs = "${var.cidrs}"
    
    subnets_tags = {
        Owner       = "${var.candidate_name}"
        Environment = "${var.environment}"
    }
}

module "mongodb" {
    source = "../../modules/mongodb"
    vpc_name = "${var.vpc_name}"

    # What are we making
    mongo_count                    = "${var.mongo_count}"
    mongo_ami                      = "${var.mongo_ami}"
    mongo_instance_type            = "${var.mongo_instance_type}"

    # Where to put it
    mongo_vpc_id                   = "${module.vpc.vpc_id}"
    mongo_subnet                   = "${module.subnets.privatedb_subnet_ids}"
   # mongo_app_sg                   = "${module.app.app_sg_id}"

    # How to build the disks and VM resources
    mongo_volume_type              = "${var.mongo_volume_type}"
    mongo_volume_size              = "${var.mongo_volume_size}"
 
    # How to provision it
    mongo_provisioning_key         = "${var.provisioning_key}"

    # How to name and tag it
    mongo_tags = {
        Name        = "Mongo01"
        Owner       = "${var.candidate_name}"
        Environment = "${var.environment}"
        Type        = "Database"
    }
}

module "app" {
    source = "../../modules/app"
    vpc_name = "${var.vpc_name}"

    # What are we making
    app_ami                 = "${var.app_ami}"
    app_instance_type       = "${var.app_instance_type}"

    # Where to put it
    app_vpc_id              = "${module.vpc.vpc_id}"
    app_public_subnet_ids             = "${module.subnets.public_subnet_ids}"
    app_privateapp_subnet_ids              = "${module.subnets.privateapp_subnet_ids}"

    # How to provision it
    app_provisioning_key            = "${var.provisioning_key}"
    app_associate_public_ip_address = "${var.app_associate_public_ip_address}"
    mongo_address               = "${module.mongodb.mongo_private_ip}"
    
    # App layer loabbalancer data points
    elb_healthy_threshold = "${var.elb_healthy_threshold}"
    elb_unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    elb_timeout = "${var.elb_timeout}"
    elb_interval = "${var.elb_interval}"

    # How to name and tag it
    app_tags = {
        Name        = "App01"
        Owner       = "${var.candidate_name}"
        Environment = "${var.environment}"
        # checking that mongodb ip address is being set as tag for debug purpose
        #Mongoaddress = "${module.mongodb.mongo_private_ip}"
        Type        = "App"
    }
}
