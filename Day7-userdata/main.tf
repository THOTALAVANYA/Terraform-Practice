resource "aws_instance" "data" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  user_data = file("test.sh")
  tags = {
    Name= "Ec2UserData"
  }
}