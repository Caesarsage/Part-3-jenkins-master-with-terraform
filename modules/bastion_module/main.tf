variable "bastion_host_sg_id" {}
variable "subnet_public" {}

# create key pair
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Management Key Pair
resource "aws_key_pair" "terraform-p-key" {
  key_name   = "terraform-p-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "terraform-server-private-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "terraform-p-key"
}

// Bastion AMI
data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["self"]
}

// Bastion instance
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.bastion.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.terraform-p-key.id
  vpc_security_group_ids      = [var.bastion_host_sg_id]
  subnet_id                   = element(var.subnet_public, 0).id
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
  }
}