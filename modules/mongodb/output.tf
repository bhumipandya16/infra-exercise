output "mongo_private_ip" {
  value = "${aws_instance.mongodb_instances.private_ip}"
}