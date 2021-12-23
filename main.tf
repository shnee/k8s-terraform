
locals {
  k8s-subnets-ids = [
    module.aws-network-existing.subnet-by-name["subnet_1"].id,
    module.aws-network-existing.subnet-by-name["subnet_3"].id,
  ]
  nodes-config = {
    "k8s-master" = {
      base-image = var.ubuntu-ami
      aws-ec2-type = var.t2-medium-4gib-2vcpu
      subnet-ids = local.k8s-subnets-ids
      num = 1
    },
    "k8s-worker" = {
      base-image = var.ubuntu-ami
      aws-ec2-type = var.t2-medium-4gib-2vcpu
      subnet-ids = local.k8s-subnets-ids
      num = 2
    },
    "ansible-test" = {
      base-image = var.ubuntu-ami
      aws-ec2-type = var.t2-micro-1gib-1vcpu
      subnet-ids = [module.aws-network-existing.subnet-by-name["subnet_2"].id]
      num = 0
    },
    "nfs" = {
      base-image = var.ubuntu-ami
      aws-ec2-type = var.t2-micro-1gib-1vcpu
      subnet-ids = [module.aws-network-existing.subnet-by-name["subnet_4"].id]
      num = 1
    },
  }
  install-qemu-agent = false
}

################################################################################
# cloud-init
################################################################################

module "cloud-init-config" {
  for_each            = local.nodes-config
  source              = "./modules/cloud-init-config"
  cloud-init-template = "${path.module}/cloud_init.cfg"
  hostname-prefix     = "${var.vm-name-prefix}-${each.key}"
  num                 = each.value.num
  root-admin-passwd   = var.root-admin-passwd
  root-admin-pub-key  = var.root-admin-pub-key
  install-qemu-agent  = local.install-qemu-agent
}

################################################################################
# aws
# To use the aws module, uncomment the aws modules/resources and comment out the
# libvirt modules/resources.
################################################################################

# This module will grab the latest ami for a variety of distros. Uncomment to
# get a list of the latest AMIs for our supported distros.
# module "aws-amis" {
#   source = "./modules/aws-amis"
# }
# output "amis" {
#   value = module.aws-amis.amis
# }

################################################################################
# AWS Networking
# Use of the 2 modules below to create resources for the AWS network.
# aws-network-from-scratch will build the AWS network from scratch.
# aws-network-existing will query AWS for an existing VPC.
################################################################################

# module "aws-network-from-scratch" {
#   source            = "./modules/aws-network-from-scratch"
#   name-prefix       = var.vm-name-prefix
#   vpc-cidr-block    = var.aws-vpc-cidr-block
#   subnet-cidr-block = var.aws-subnet-cidr-block
#   admin-ips         = var.admin-ips
# }

module "aws-network-existing" {
  source                      = "./modules/aws-network-existing"
  default-vpc-name            = var.aws-existing-vpc-name
  default-security-group-name = var.aws-existing-sg-name
  existing-subnet-names       = var.aws-existing-subnet-names
}

################################################################################

# This key pair is not actually used. Keys are added to the nodes via cloud-init
# instead. We just add this here that this key will show up in the AWS console."
resource "aws_key_pair" "key" {
  key_name   = "${var.vm-name-prefix}-key}"
  public_key = var.root-admin-pub-key
  tags = {
    Name = "${var.vm-name-prefix}-key"
  }
}

# resource "aws_ebs_volume" "zfs" {
#   availability_zone =

module "nodes" {
  for_each           = local.nodes-config
  source             = "./modules/aws-nodes"
  ami                = each.value.base-image
  subnet-ids         = each.value.subnet-ids
  security-group-ids = [module.aws-network-existing.default-sg.id]
  user-datas         = lookup(module.cloud-init-config, each.key, null).user-datas
  num-nodes          = each.value.num
  name-prefix        = "${var.vm-name-prefix}-${each.key}"
  # TODO add a input for the key so that it will show up as the key in the aws
  # console.
}

################################################################################
# end aws
################################################################################

################################################################################
# libvirt
# To use the libvirt module, uncomment the libvirt modules/resources and comment
# out the aws modules/resources.
################################################################################

# provider "libvirt" {
#   uri = var.libvirt-connection-url
# }
#
# module "nodes" {
#   for_each               = local.nodes-config
#   source                 = "./modules/libvirt-nodes"
#   pool-name              = libvirt_pool.images.name
#   name-prefix            = "${var.vm-name-prefix}-${each.key}"
#   num-nodes              = each.value.num
#   node-memory            = var.node-memory
#   node-vcpus             = var.node-vcpus
#   node-disk-size         = var.libvirt-node-disk-size
#   base-image             = each.value.base-image
#   network-name           = var.libvirt-network-name
#   root-admin-passwd      = var.root-admin-passwd
#   root-admin-pub-key     = var.root-admin-pub-key
#   libvirt-connection-url = var.libvirt-connection-url
#   user-datas             = lookup(module.cloud-init-config, each.key, null).user-datas
# }
#
# resource "libvirt_pool" "images" {
#   name = var.disk-image-pool-name
#   type = "dir"
#   path = var.disk-image-dir
# }

################################################################################
# end libvirt
################################################################################

# This will outpus a map of group => [{hostname, ip}].
# TODO A 'names' output needs to be added to libvirt.
output "groups_hostnames_ips" {
  value = { for type, node in module.nodes : type => zipmap(node.names, node.ips) }
}

# This will outpus a map of group => [{hostname, private_ip}].
# TODO Figure out how what to do about private_ips for libvirt.
output "groups_hostnames_private_ips" {
  value = { for type, node in module.nodes : type => zipmap(node.names, node.private_ips) }
}
