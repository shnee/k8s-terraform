output "ips" {
  value = aws_instance.nodes.*.public_ip
}

output "names" {
  value = aws_instance.nodes.*.tags.Name
}
