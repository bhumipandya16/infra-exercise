output "elb-dns-url-name" {
  value = "${aws_elb.lb.dns_name}"
}

output "dev-app-test-url" {
  value = "http://${aws_elb.lb.dns_name}/test.htm"
}

output "dev-app-mongoquery-data-url" {
  value = "http://${aws_elb.lb.dns_name}/query.json"
}

output "bastionhost_sg_id" {
  value = "${aws_security_group.bastionhost_sg.id}"
}