terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

################################################################################
# cloud-init
################################################################################

data "template_file" "master-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-master-${count.index}"
  }
  count = var.master-nodes
}

data "template_file" "worker-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-worker-${count.index}"
  }
  count = var.worker-nodes
}

################################################################################
# aws
# To use the aws module, uncomment the aws modules/resources and comment out the
# libvirt modules/resources.
################################################################################

provider "aws" {
  region = "us-east-2"
}

module "aws-amis" {
  source = "./modules/aws-amis"
}

module "aws-network" {
  source = "./modules/aws-network"
  name-prefix = var.vm-name-prefix
  vpc-cidr-block = var.aws-vpc-cidr-block
  subnet-cidr-block = var.aws-subnet-cidr-block
  admin-ips = var.admin-ips
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

module "master-nodes" {
  source             = "./modules/aws-nodes"
  ami                = var.base-image
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.master-node-user-datas
  num-nodes          = var.master-nodes
  name-prefix        = "${var.vm-name-prefix}-master"
}

module "worker-nodes" {
  source             = "./modules/aws-nodes"
  ami                = var.base-image
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.worker-node-user-datas
  num-nodes          = var.worker-nodes
  name-prefix        = "${var.vm-name-prefix}-worker"
}

output "amis" {
  value = module.aws-amis.amis
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
# module "master-nodes" {
#   source                 = "./modules/libvirt-nodes"
#   pool-name              = libvirt_pool.images.name
#   name-prefix            = "${var.vm-name-prefix}-master"
#   num-nodes              = var.master-nodes
#   node-memory            = var.node-memory
#   node-vcpus             = var.node-vcpus
#   base-image             = var.base-image
#   root-admin-passwd      = var.root-admin-passwd
#   root-admin-pub-key     = var.root-admin-pub-key
#   libvirt-connection-url = var.libvirt-connection-url
#   user-datas             = data.template_file.master-node-user-datas
# }
# 
# module "worker-nodes" {
#   source                 = "./modules/libvirt-nodes"
#   pool-name              = libvirt_pool.images.name
#   name-prefix            = "${var.vm-name-prefix}-worker"
#   num-nodes              = var.worker-nodes
#   node-memory            = var.node-memory
#   node-vcpus             = var.node-vcpus
#   base-image             = var.base-image
#   root-admin-passwd      = var.root-admin-passwd
#   root-admin-pub-key     = var.root-admin-pub-key
#   libvirt-connection-url = var.libvirt-connection-url
#   user-datas             = data.template_file.worker-node-user-datas
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

# TODO REM move to other file?
output "master-ips" {
  value = module.master-nodes.ips
}

output "worker-ips" {
  value = module.worker-nodes.ips
}
