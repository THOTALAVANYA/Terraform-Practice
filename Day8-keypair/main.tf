resource "aws_key_pair" "my-key-pair" {
  key_name = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # taking the path from local

}

resource "aws_instance" "keypair-ec2" {
  ami =var.ami
  instance_type = var.instance_type
  key_name = aws_key_pair.my-key-pair.key_name
  tags = {
    Name ="MyTerraformInstance"
  }
}