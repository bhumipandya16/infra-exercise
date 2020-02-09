# Create helpful outputs here..

output "VPC ID:"   { value = "${module.vpc.vpc_id}" }
output "VPC CIDR:" { value = "${module.vpc.vpc_cidr}" }


# output for app dns name and urls

output "ELB_DNS_NAME:" {
  value = "${module.app.elb-dns-url-name}"
}

output "Application_test_url:" {
  value = "${module.app.dev-app-test-url}"
}

output "Application_MongoDb_Url:" {
  value = "${module.app.dev-app-mongoquery-data-url}"
}

