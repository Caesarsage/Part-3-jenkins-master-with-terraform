resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_nat_id
  subnet_id     = element(var.subnet_public.*.id, 0)
  tags = {
    Name = "nat_${var.vpc_name}"
  }
}
