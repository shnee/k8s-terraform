output "ips" {
  value = aws_instance.nodes.*.public_ip
}

output "private_ips" {
  value = aws_instance.nodes.*.private_ip
}

output "names" {
  value = aws_instance.nodes.*.tags.Name
}
