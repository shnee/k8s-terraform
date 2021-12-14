locals {
  az-to-subnets = {
    for s in data.aws_subnet.subnets : s.availability_zone => s.id...
  }
}

data "aws_vpc" "default" {
  tags = {
    Name = var.default-vpc-name
  }
}

data "aws_subnets" "subnet-ids" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "subnets" {
  for_each = toset(data.aws_subnets.subnet-ids.ids)
  id = each.key
}
