module "test" {
  source        = "../Day9-modules"
  ami           = "ami-0866a3c8686eaeeba"
  instance_type = "t2.micro"
  key_name = "task"
  tags = {
    Name ="ModuleEC2"
  }
}
