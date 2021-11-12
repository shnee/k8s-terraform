terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}

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

data "template_file" "node-user-datas" {
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    admin-passwd  = "${var.root-admin-passwd}"
    admin-pub-key = "${var.root-admin-pub-key}"
    hostname      = "${var.vm-name-prefix}-${count.index}"
  }
  count = var.master-nodes
}

resource "aws_instance" "test-node" {
  ami                         = var.base-image
  instance_type               = var.aws-ec2-instance-type
  # key_name                    = aws_key_pair.debug1.key_name
  associate_public_ip_address = true
  subnet_id                   = module.aws-network.subnet.id
  vpc_security_group_ids = [module.aws-network.default-security-group.id]
  user_data = element(data.template_file.node-user-datas.*.rendered, count.index)
  count                       = var.master-nodes

  tags = {
    Name = "${var.vm-name-prefix}-test"
  }
}

output "master-ips" {
  value = aws_instance.test-node.*.public_ip
}

# provider "libvirt" {
#   uri = var.libvirt-connection-url
# }
# 
# module "master-nodes" {
#   source = "./modules/libvirt-nodes"
#   pool-name = libvirt_pool.images.name
#   name-prefix = "${var.vm-name-prefix}-master"
#   num-nodes = var.master-nodes
#   node-memory = var.node-memory
#   node-vcpus = var.node-vcpus
#   base-image = var.base-image
#   root-admin-passwd = var.root-admin-passwd
#   root-admin-pub-key = var.root-admin-pub-key
#   libvirt-connection-url = var.libvirt-connection-url
# }
# 
# module "worker-nodes" {
#   source = "./modules/libvirt-nodes"
#   pool-name = libvirt_pool.images.name
#   name-prefix = "${var.vm-name-prefix}-worker"
#   num-nodes = var.worker-nodes
#   node-memory = var.node-memory
#   node-vcpus = var.node-vcpus
#   base-image = var.base-image
#   root-admin-passwd = var.root-admin-passwd
#   root-admin-pub-key = var.root-admin-pub-key
#   libvirt-connection-url = var.libvirt-connection-url
# }
# 
# resource "libvirt_pool" "images" {
#   name = var.disk-image-pool-name
#   type = "dir"
#   path = var.disk-image-dir
# }
# 
# # TODO REM move to other file?
# output "master-ips" {
#   value = module.master-nodes.ips
# }
# 
# output "worker-ips" {
#   value = module.worker-nodes.ips
# }
