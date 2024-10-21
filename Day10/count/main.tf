#example1:without list varaible 
# resource "aws_instance" "myec2" {
#     ami = "ami-0230bd60aa48260c6"
#     instance_type = "t2.micro"
#     count = 2
#     tags = {
#       Name = "webec2"
#       Name = "webec2-${count.index}"
#     }
# }

# example-2 with variables list of string 
resource "aws_instance" "sandbox" {
  ami           = var.ami
  instance_type = var.instance_type
  count         = length(var.sandboxes)

  tags = {
    Name = var.sandboxes[count.index]
  }
}
#example-3 with creating IAM users using count
resource "aws_iam_user" "myusers" {
    count = length(var.iam_users)
    name = var.iam_users[count.index]
}

# example-4 with numeric condition if ec2 instance = t2.micro only 
# instance will create(count = var.instance_type == "t2.micro" ? 1 : 0) 
# but i am passing t2.nano so ec2 will not create
resource "aws_instance" "count-ec2" {
  ami = var.ami
  instance_type = "t2.nano"
  count = var.instance_type == "t2.micro" ? 1 : 0
  tags = {
    Name = "CountEC2"
  }
}