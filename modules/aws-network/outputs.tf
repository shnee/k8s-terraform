output "vpc" {
  value = aws_vpc.vpc
}

output "subnet" {
  value = aws_subnet.subnet
}

output "default-security-group" {
  value = aws_default_security_group.sg
}
