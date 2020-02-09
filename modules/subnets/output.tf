output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "privateapp_subnet_ids" {
  value = "${aws_subnet.privateapp_subnet.*.id}"
}

output "privatedb_subnet_ids" {
  value = "${aws_subnet.privatedb_subnet.*.id}"
}

output "public_rt_id" {
  value = "${aws_route_table.app_public_rt.id}"
}

output "default_private_rt_id" {
  value = "${aws_default_route_table.app_private_rt.default_route_table_id}"
}