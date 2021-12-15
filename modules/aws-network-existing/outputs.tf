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

output "k8s-subnets-ids" {
  description = "An array of subnets to be used for k8s VMs. These subnets were chosen by selecting a single subnet from each availability_zone."
  value = [for k,v in local.az-to-subnets : v[0]]
}

output "az-to-subnets" {
  description = "A map of availability zone to array of subnets that are in thet availability zone."
  value = local.az-to-subnets
}
