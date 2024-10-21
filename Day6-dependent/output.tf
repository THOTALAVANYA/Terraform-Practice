output "public_ip" {
  value = aws_instance.dependent.public_ip
}

output "private_ip" {
  value = aws_instance.dependent.private_ip
}