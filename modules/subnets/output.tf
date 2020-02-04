output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet.*.id}"
}

output "privateapp_subnet_ids" {
  value = "${aws_subnet.privateapp_subnet.*.id}"
}

output "privatedb_subnet_ids" {
  value = "${aws_subnet.privatedb_subnet.*.id}"
}