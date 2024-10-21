resource "aws_instance" "sample" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  tags = {
    Name = "Terraform Backend"
  }
}