resource "aws_instance" "name" {
  ami           = data.aws_ami.sample.id
  instance_type = var.instance_type
  #   key_name        = var.instance_type
  subnet_id = data.aws_subnet.sample.id
  security_groups = [data.aws_security_group.sample.id]
  tags = {
    Name = " Datasource-ec2"
  }
}


