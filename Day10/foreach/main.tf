resource "aws_instance" "for-each-ec2" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  for_each = toset(var.instance_names)
  tags = {
    Name = each.key
  }
}