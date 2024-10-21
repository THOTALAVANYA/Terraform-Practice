resource "aws_instance" "dependent" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  tags = {
    Name = "Day6Ec2"
  }
  depends_on = [ aws_s3_bucket.dependent ]
}

resource "aws_s3_bucket" "dependent" {
  bucket = "mys3bucket-terraform-dependent"
}