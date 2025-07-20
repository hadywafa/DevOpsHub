output "server_public_ip" {
  value = aws_instance.hw_instance.public_ip
}
