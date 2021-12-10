terraform {
  required_version = ">= 1.0.8"

    backend "s3" {
      
      bucket            = "mss-terraform-state"
      key               = "global/s3/terraform.tfstate"
      region            = "us-gov-west-1"
      
      dynamodb_table    = "mss-terraform-state-lock"
      encrypt           = true

  }
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

locals {
  nodes-config = {
    "master" = {
      base-image = var.centos8-ami
      num = 1
    },
    "worker" = {
      base-image = var.centos8-ami
      num = 2
    }
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

provider "aws" {
  region = "us-gov-west-1"
}

# This module will grab the latest ami for a variety of distros. Uncomment to
# get a list of the latest AMIs for our supported distros.
# module "aws-amis" {
#   source = "./modules/aws-amis"
# }
# output "amis" {
#   value = module.aws-amis.amis
# }

module "aws-network" {
  source            = "./modules/aws-network"
  name-prefix       = var.vm-name-prefix
  vpc-cidr-block    = var.aws-vpc-cidr-block
  subnet-cidr-block = var.aws-subnet-cidr-block
  admin-ips         = var.admin-ips
}

# This key pair is not actually used. Keys are added to the nodes via cloud-init
# instead. We just add this here that this key will show up in the AWS console."
resource "aws_key_pair" "key" {
  key_name   = "${var.vm-name-prefix}-key}"
  public_key = var.root-admin-pub-key
  tags = {
    Name = "${var.vm-name-prefix}-key"
  }
}

module "nodes" {
  for_each           = local.nodes-config
  source             = "./modules/aws-nodes"
  ami                = each.value.base-image
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = lookup(module.cloud-init-config, each.key, null).user-datas
  num-nodes          = each.value.num
  name-prefix        = "${var.vm-name-prefix}-${each.key}"
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
