variable "jenkins_master_sg_id" {}
variable "subnet_private" {}
variable "alb_jenkins_sg_id" {}
variable "subnet_public" {}
variable "vpc_id" {}

data "aws_ami" "jenkins-master" {
  most_recent = true
  owners      = ["self"]
}

# create key pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Management Key Pair
resource "aws_key_pair" "terraform-jenkins-key" {
  key_name   = "terraform-jenkins-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "terraform-server-private-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "terraform-jenkins-key"
}

resource "aws_instance" "jenkins_master" {
  ami                    = data.aws_ami.jenkins-master.id
  instance_type          = "t2.large"
  key_name               = aws_key_pair.terraform-jenkins-key.id
  vpc_security_group_ids = [var.jenkins_master_sg_id]
  subnet_id              = element(var.subnet_private, 0).id

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = false
  }

  tags = {
    Name = "jenkins_master"
  }
}


# Create an Application Load Balancer
resource "aws_lb" "jenkins_alb" {
  name               = "jenkins-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [for subnet in var.subnet_public : subnet.id]
  security_groups    = [var.alb_jenkins_sg_id]

  tags = {
    Name = "jenkins-lb"
  }

}

resource "aws_lb_target_group" "jenkins-lb-target-group" {
  name     = "jenkins-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  # Configure Health Check for Target Group
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "403"
    interval            = 15
    timeout             = 6
    healthy_threshold   = 3
    unhealthy_threshold = 10
  }

  tags = {
    Name = "jenkins_load_balancer_tg"
  }
}

# Configure Listeners for ALB
resource "aws_lb_listener" "jenkins_lb_listener" {
  load_balancer_arn = aws_lb.jenkins_alb.arn
  port              = 8080
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }

  tags = {
    Name = "jenkins_lb_listener"
  }
}

# // Jenkins ELB
# resource "aws_elb" "jenkins_elb" {
#   instances = [aws_instance.jenkins_master.id]




#   # listener {
#   #   instance_port      = 8080
#   #   instance_protocol  = "http"
#   #   lb_port            = 443
#   #   lb_protocol        = "https"
#   #   ssl_certificate_id = var.ssl_arn
#   # }
#   tags = {
#     Name   = "jenkins_elb"
#   }
# }