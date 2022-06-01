resource "aws_eip" "nat" {
  vpc = true
  
  tags = {
    Name = "eip-nat_${var.vpc_name}"
  }
}