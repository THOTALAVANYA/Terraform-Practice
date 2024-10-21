resource "aws_instance" "myec2" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = aws_subnet.mysubnet.id
  associate_public_ip_address = true
  security_groups = [aws_security_group.custnw_sg.id]
  tags = {
    Name = "MYEC2"
  }
}