# variable "public_key" {}

# # create key pair
# resource "tls_private_key" "rsa" {
#   algorithm = "RSA"
#   rsa_bits = 4096
# }

# // Management Key Pair
# resource "aws_key_pair" "terraform-server-key" {
#   key_name   = "terraform-key"
#   public_key = "${tls_private_key.rsa.public_key_openssh}"
# }

# resource "local_file" "terraform-server-private-key" {
#   content = "${tls_private_key.rsa.private_key_pem}"
#   filename = "terraform-key"
# }