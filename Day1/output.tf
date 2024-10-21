output "public_ip" {
  value = aws_instance.example.public_ip
  sensitive = true
}

output "private_ip" {
  value = aws_instance.example.private_ip
}