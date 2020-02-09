output "vpc_id"     { value = "${aws_vpc.main.id}" }
output "vpc_cidr"   { value = "${aws_vpc.main.cidr_block}" }
output "vpc_igw_id" { value = "${aws_internet_gateway.main.id}" }
output "default_route_table_id" { value = "${aws_vpc.main.default_route_table_id}" }