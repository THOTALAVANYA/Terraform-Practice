data "aws_ami" "sample" {
  most_recent = true
  owners = [ "amazon" ]
  filter {
    name = "name"
    values = [ "amzn2-ami-hvm-*-gp2" ]
  }
  filter {
    name = "root-device-type"
    values = [ "ebs" ]
  }
  filter {
    name = "virtualization-type"
    values = [ "hvm" ]
  }
  filter {
    name = "architecture"
    values = [ "x86_64" ]
  }
}

data "aws_security_group" "sample" {
  #id= "sg-03391b2887b7fa699" #here w ecan change your security group(sg) id details
  #rather than hardcoding id directly we can filter based on the name
  filter {
    name = "tag: Name"
    values = ["custnw_sg"]
  }
}

data "aws_subnet" "sample" {
  #id= "subnet-0405c0676109d749d"
  filter {
    name = "tag: Name"
    values = ["my_public_subnet"]
  }
}

# data "aws_vpc" "sample" {
#   id= "vpc-09b4ca9e43a5b1392"
# }