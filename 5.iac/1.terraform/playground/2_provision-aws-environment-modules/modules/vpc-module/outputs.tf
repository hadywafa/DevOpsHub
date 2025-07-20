output "vpc_id" {
  value = aws_vpc.hw_vpc.id
}

output "subnet_id" {
  value = aws_subnet.hw_subnet.id
}
