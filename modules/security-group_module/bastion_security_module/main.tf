variable "vpc_name" {}
variable "vpc_id" {}

// Bastion Security group
resource "aws_security_group" "bastion_host" {
  name        = "bastion_sg_${var.vpc_name}"
  description = "Allow SSH from anywhere"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "bastion_sg_${var.vpc_name}"
  }
}
