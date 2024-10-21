#1. creating VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "custom_vpc"
  }
}

#2.Creating IG(Internet Gateway) and attach to VPC
resource "aws_internet_gateway" "myIG" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "My_internet_gateway"
  }
}

#3.Create Subnets
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "my_public_subnet"
  }
}

#4. Create RT(Routing table) and attacg to VPC
resource "aws_route_table" "myRT" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "my_route_table"
  }
}

#associate route table with internetgateway
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.myRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIG.id
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.myRT.id
}

#custom Security Group
resource "aws_security_group" "custnw_sg" {
  name        = "custnw_sg"
  description = "Allow TLS inbound traffics"
  vpc_id      = aws_vpc.myvpc.id 

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
