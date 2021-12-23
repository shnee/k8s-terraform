output "default-vpc" {
  value = data.aws_vpc.default
}

output "default-sg" {
  value = data.aws_security_group.default
}

output "subnets" {
  description = "An array of all subnets in default-vpc."
  value = data.aws_subnet.subnets
}

output "one-subnet-per-az" {
  description = "An array of subnets that selects 1 subnet per az."
  value = [for k,v in local.az-to-subnets : v[0]]
}

output "subnet-by-name" {
  description = "A map of subnet name to subnet resource."
  value = data.aws_subnet.subnet-by-name
}

output "az-to-subnets" {
  description = "A map of availability zone to array of subnets that are in thet availability zone."
  value = local.az-to-subnets
}
