output "public_ip" {
  value = aws_instance.sample.public_ip
}

output "private_ip" {
  value = aws_instance.sample.private_ip
}