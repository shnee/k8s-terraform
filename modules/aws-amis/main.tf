locals {
  amis = {
    amzn2 = {
      owner-id = "137112412989"
      name = "amzn2-ami-hvm-2*x86_64-gp2"
    },
    ubuntu = {
      owner-id = "099720109477"
      name = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    },
    centos7 = {
      owner-id = "125523088429"
      name = "CentOS 7.*x86_64"
    },
    centos8 = {
      owner-id = "125523088429"
      name = "CentOS 8.*x86_64"
    },
    arch = {
      owner-id = "093273469852"
      name = "arch-linux-lts-hvm*x86_64-ebs"
    },
    rhel7 = {
      owner-id = "309956199498"
      name = "RHEL-7.*HVM*x86_64*GP2"
    },
    rhel8 = {
      owner-id = "309956199498"
      name = "RHEL-8.*HVM*x86_64*GP2"
    }
  }
}

data "aws_ami" "amis" {
  for_each = local.amis
  most_recent = true
  owners = [each.value.owner-id]

  filter {
    name = "name"
    values = [each.value.name]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
}
