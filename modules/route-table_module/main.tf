resource "aws_route_table" "public_rt" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
  }
  tags = {
    Name = "public_rt_${var.vpc_name}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_id}"
  }
  tags = {
    Name = "private_rt_${var.vpc_name}"
  }
}
