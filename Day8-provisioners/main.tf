#----Type of provisioners-------
# 1.local-exec
# 2.remote-exec
# 3.file

resource "aws_key_pair" "mykeypair" {
  key_name   = "task"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "mysubnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "new-sg" {
  name   = "new-web-sg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "new-web-sg"
  }

}

resource "aws_instance" "provisioner-ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.new-sg.id]
  subnet_id              = aws_subnet.mysubnet.id
  tags = {
    Name = "ProvisionerEC2"
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa") #private key path
    host        = self.public_ip
  }
  #local execution process
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip_address.txt"
  }
  #File provisioner to copy a file from local to the remote EC2 instance
  provisioner "file" {
    source      = "file-provisioner"
    destination = "/home/ubuntu/file-provisioner"
  }
  #remote exceution process
  provisioner "remote-exec" {
    inline = [
      "touch remote-provisioner",
      "echo Hello from AWS >> remote-provisioner",
    ]
  }
}
