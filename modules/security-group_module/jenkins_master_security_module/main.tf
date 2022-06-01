variable "baston_host_sg_id" {}
variable "alb_jenkins_sg_id" {}
variable "vpc_name" {}
variable "vpc_id" {}

resource "aws_security_group" "jenkins_master_sg" {
  name        = "jenkins_master_sg"
  description = "Allow traffic on port 8080 and enable SSH"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    security_groups = [var.baston_host_sg_id]
  }

  ingress {
    from_port       = "8080"
    to_port         = "8080"
    protocol        = "tcp"
    security_groups = [var.alb_jenkins_sg_id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "jenkins_master_sg"
  }
}

output "jenkins_master_id" {
  value = "${aws_security_group.jenkins_master_sg.id}"
}