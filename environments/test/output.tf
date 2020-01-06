# Create helpful outputs here..

output "VPC ID:"   { value = "${module.vpc.vpc_id}" }
output "VPC CIDR:" { value = "${module.vpc.vpc_cidr}" }

# output for app public ip address..?