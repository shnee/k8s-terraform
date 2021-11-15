output "ips" {
  value = aws_instance.nodes.*.public_ip
}
