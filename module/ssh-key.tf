#resource "tls_private_key" "ssh_private_key" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

#resource "aws_key_pair" "ssh_public_key" {
#  key_name   = "worker-22a"
#  public_key = tls_private_key.example.public_key_openssh
#}
