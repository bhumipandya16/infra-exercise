# Unit test module with below module

# module "vpc" {
#   source = "../vpc"

#   vpc_name = "${var.vpc_name}" # Let's make sure this gets added as a tag
#   vpc_cidr = "${var.vpc_cidr}"

#   vpc_enable_dns_hostnames    = "${var.vpc_enable_dns_hostnames}"
#   vpc_enable_dns_support      = "${var.vpc_enable_dns_support}"
#   vpc_create_internet_gateway = "${var.vpc_create_internet_gateway}"

#   vpc_tags = {
#     Owner       = "${var.candidate_name}"
#     Environment = "${var.environment}"
#   }
# }


# module "subnets" {
#     source = "../../modules/subnets"

#     subnets_target_vpc_id      = "${module.vpc.vpc_id}"
#     subnets_target_vpc_igw_id  = "${module.vpc.vpc_igw_id}"
#     public_route_table_id = "${module.vpc.public_rt_id}"
#     default_rotue_table_id = "${module.vpc.default_private_rt_id}"
#     cidrs = "${var.cidrs}"
#     subnets_az_state_filter    = "${var.subnets_az_state_filter}"
#     subnets_private_count      = "${var.subnets_private_count}"  # Let's make sure to use distinct AZs for each
#     subnets_public_count       = "${var.subnets_public_count}"
#     subnets_enable_nat_gateway = "${var.subnets_enable_nat_gateway}"

#     subnets_tags = {
#         Owner       = "${var.candidate_name}"
#         Environment = "${var.environment}"
#     }
# }

# Bastion Host to access resouces

resource "aws_security_group" "bastionhost_sg" {
  name        = "bastionhost_sg"
  description = "Used for access to the bastionhost instance mostly to SSH to private resouces"
  vpc_id      = "${var.app_vpc_id}"

  #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ## out bound connection TODO: validate from security point of view
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = "${merge(var.app_tags, map("Name", format("%s_bastionhost_sg", var.vpc_name)))}"
}


# #key pair

resource "aws_key_pair" "app_auth" {
  key_name   = "app_key"
  public_key = "${var.app_provisioning_key}"
}

## challange faced when mongo and app instaces are build userdata script was not having mongodb ip address. 
# template file data and .rendered attribute helped to address the challange to pass one module output to another mondue data file

data "template_file" "userdata_file" {
  template = "${file("${path.module}/templates/user_data.tpl")}"
  vars = {
    mongo_address = "${var.mongo_address}"
  } 
}

# Bastion host to connect over public internet to validate the private instances

resource "aws_instance" "bastionhost_app_server" {
  instance_type = "${var.app_instance_type}"
  ami           = "${var.app_ami}"

  tags = "${merge(var.app_tags, map("Name", format("%s_bastionhost_instance", var.vpc_name)))}"

  key_name               = "${aws_key_pair.app_auth.id}"
  vpc_security_group_ids = ["${aws_security_group.bastionhost_sg.id}"]
  subnet_id              = "${var.app_public_subnet_ids[0]}"
  associate_public_ip_address = "${var.app_associate_public_ip_address}"
 
  user_data = "${data.template_file.userdata_file.rendered}"
}

## Security Groups 
### Load balancer security group
resource "aws_security_group" "lb_sg" {
  name = "${var.vpc_name}_public_lb_sg"
  description = "Used for access to public loadbalancer layer"
  vpc_id = "${var.app_vpc_id}"

  # HTTP traffic

  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic

  egress{
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.app_layer_sg.id}"]
  }

   tags = "${merge(var.app_tags, map("Name", format("%s_lb_sg", var.vpc_name)))}"


}

### App server security group

resource "aws_security_group" "app_layer_sg" {
  name = "${var.vpc_name}_app_layer_sg"
  description = "Used for access to application instaces layer"
  vpc_id = "${var.app_vpc_id}"

  #http
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   #SSH

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
     security_groups = ["${aws_security_group.bastionhost_sg.id}"]
  }

  #outbound  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = "${merge(var.app_tags, map("Name", format("%s_app_layer_sg", var.vpc_name)))}"

}


## Public subnet resouces load balancer layer

resource "aws_elb" "lb" {
  name = "${var.vpc_name}-elb"

  subnets = ["${var.app_public_subnet_ids}"]

  security_groups = ["${aws_security_group.lb_sg.id}"]

  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check{
    healthy_threshold   = "${var.elb_healthy_threshold}"
    unhealthy_threshold = "${var.elb_unhealthy_threshold}"
    timeout             = "${var.elb_timeout}"
    target              = "TCP:8080"
    interval            = "${var.elb_interval}"
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

   tags = "${merge(var.app_tags, map("Name", format("%s_elb", var.vpc_name)))}"

  
}


## Private subnet auto scaling app layer

#launch configuration

resource "aws_launch_configuration" "app_lc" {
  name_prefix          = "${var.vpc_name}_lc-"

  image_id             = "${var.app_ami}"
  instance_type        = "${var.app_instance_type}"
  security_groups      = ["${aws_security_group.app_layer_sg.id}"]
  key_name             = "${aws_key_pair.app_auth.id}"
  user_data            = "${data.template_file.userdata_file.rendered}"

  

  lifecycle {
    create_before_destroy = true
  }
}

#ASG 

#resource "random_id" "rand_asg" {
# byte_length = 8
#}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.vpc_name}-asg-${aws_launch_configuration.app_lc.id}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.asg_grace}"
  health_check_type         = "${var.asg_hct}"
  desired_capacity          = "${var.asg_cap}"
  force_delete              = true
  load_balancers            = ["${aws_elb.lb.id}"]

  vpc_zone_identifier = ["${var.app_privateapp_subnet_ids}"]

  launch_configuration = "${aws_launch_configuration.app_lc.name}"

 

  lifecycle {
    create_before_destroy = true
  }
}


## 