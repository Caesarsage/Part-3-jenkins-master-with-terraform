resource "aws_subnet" "public_subnet" {
  vpc_id                         = "${var.vpc_id}"
  cidr_block                     = "10.0.${count.index * 2 + 1}.0/24"
  availability_zone              = element(var.availability_zone, count.index)
  map_public_ip_on_launch         = true

  count                          = "${var.public_subnets_count}"

  tags = {
    Name = "public_10.0.${count.index *2 + 1}.0_${element(var.availability_zone, count.index)}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                         = "${var.vpc_id}"
  cidr_block                     = "10.0.${count.index * 2}.0/24"
  availability_zone              = element(var.availability_zone, count.index)
  map_public_ip_on_launch         = false

  count                          = "${var.private_subnets_count}"

  tags = {
    Name = "private_10.0.${count.index *2}.0_element(var.availability_zone, count.index)"
  }
}


# assign public subnet to the route table
resource "aws_route_table_association" "subnet-public-association" {
  count          = "${var.public_subnets_count}"
  subnet_id      = element("${aws_subnet.public_subnet.*.id}", count.index)
  route_table_id = "${var.public_rt_id}"
}

# assign private subnet to the route table
resource "aws_route_table_association" "subnet-private-association" {
  count           = "${var.private_subnets_count}"
  subnet_id       = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id  = "${var.private_rt_id}"
}