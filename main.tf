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

# data "template_file" "master-node-user-datas" {
#   template = file("${path.module}/cloud_init.cfg")
#   vars = {
#     admin-passwd  = "${var.root-admin-passwd}"
#     admin-pub-key = "${var.root-admin-pub-key}"
#     hostname      = "${var.vm-name-prefix}-master-${count.index}"
#   }
#   count = var.master-nodes
# }
# 
# data "template_file" "worker-node-user-datas" {
#   template = file("${path.module}/cloud_init.cfg")
#   vars = {
#     admin-passwd  = "${var.root-admin-passwd}"
#     admin-pub-key = "${var.root-admin-pub-key}"
#     hostname      = "${var.vm-name-prefix}-worker-${count.index}"
#   }
#   count = var.worker-nodes
# }

data "template_file" "amzn2-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-amzn2-${count.index}"
  }
  count = 1
}

data "template_file" "ubuntu-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-ubuntu-${count.index}"
  }
  count = 1
}

data "template_file" "arch-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-arch-${count.index}"
  }
  count = 1
}

data "template_file" "centos7-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-centos7-${count.index}"
  }
  count = 1
}

data "template_file" "centos8-node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-centos8-${count.index}"
  }
  count = 1
}

################################################################################
# aws
# To use the aws module, uncomment the aws modules/resources and comment out the
# libvirt modules/resources.
################################################################################

provider "aws" {
  region = "us-east-2"
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

module "amzn2-nodes" {
  source             = "./modules/aws-nodes"
  ami                = var.base-image
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.amzn2-node-user-datas
  num-nodes          = 1
  name-prefix        = "${var.vm-name-prefix}-amzn2"
}

module "ubuntu-nodes" {
  source             = "./modules/aws-nodes"
  ami                = "ami-0629230e074c580f2"
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.ubuntu-node-user-datas
  num-nodes          = 1
  name-prefix        = "${var.vm-name-prefix}-ubuntu"
}

module "arch-nodes" {
  source             = "./modules/aws-nodes"
  ami                = "ami-02653f06de985e3ba"
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.ubuntu-node-user-datas
  num-nodes          = 1
  name-prefix        = "${var.vm-name-prefix}-arch"
}

module "centos7-nodes" {
  source             = "./modules/aws-nodes"
  ami                = "ami-00f8e2c955f7ffa9b"
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.ubuntu-node-user-datas
  num-nodes          = 1
  name-prefix        = "${var.vm-name-prefix}-centos7"
}

module "centos8-nodes" {
  source             = "./modules/aws-nodes"
  ami                = "ami-057cacbfbbb471bb3"
  ec2-instance-type  = var.aws-ec2-instance-type
  subnet-id          = module.aws-network.subnet.id
  security-group-ids = [module.aws-network.default-security-group.id]
  user-datas         = data.template_file.ubuntu-node-user-datas
  num-nodes          = 1
  name-prefix        = "${var.vm-name-prefix}-centos8"
}

# module "master-nodes" {
#   source             = "./modules/aws-nodes"
#   ami                = var.base-image
#   ec2-instance-type  = var.aws-ec2-instance-type
#   subnet-id          = module.aws-network.subnet.id
#   security-group-ids = [module.aws-network.default-security-group.id]
#   user-datas         = data.template_file.master-node-user-datas
#   num-nodes          = var.master-nodes
#   name-prefix        = "${var.vm-name-prefix}-master"
# }
# 
# module "worker-nodes" {
#   source             = "./modules/aws-nodes"
#   ami                = var.base-image
#   ec2-instance-type  = var.aws-ec2-instance-type
#   subnet-id          = module.aws-network.subnet.id
#   security-group-ids = [module.aws-network.default-security-group.id]
#   user-datas         = data.template_file.worker-node-user-datas
#   num-nodes          = var.worker-nodes
#   name-prefix        = "${var.vm-name-prefix}-worker"
# }

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

output "amzn2-ips" {
  value = module.amzn2-nodes.ips
}

output "ubuntu-ips" {
  value = module.ubuntu-nodes.ips
}

output "arch-ips" {
  value = module.arch-nodes.ips
}

output "centos7-ips" {
  value = module.centos7-nodes.ips
}

output "centos8-ips" {
  value = module.centos8-nodes.ips
}

# TODO REM move to other file?
# output "master-ips" {
#   value = module.master-nodes.ips
# }
# 
# output "worker-ips" {
#   value = module.worker-nodes.ips
# }
