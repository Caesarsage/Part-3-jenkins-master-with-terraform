resource "aws_vpc" "vpc-module" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.vpc_name}"
  }
}