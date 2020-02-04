output "vpc_id"     { value = "${aws_vpc.main.id}" }
output "vpc_cidr"   { value = "${aws_vpc.main.cidr_block}" }
output "vpc_igw_id" { value = "${aws_internet_gateway.main.id}" }
output "public_rt_id" {
  value = "${aws_route_table.app_public_rt.id}"
}

output "default_private_rt_id" {
  value = "${aws_default_route_table.app_private_rt.default_route_table_id}"
}