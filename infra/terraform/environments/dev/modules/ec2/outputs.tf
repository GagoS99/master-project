output "elastic_ip" {
  value = aws_eip.main.public_ip
}
