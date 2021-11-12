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

resource "aws_vpc" "vpc" {
  cidr_block = var.aws-vpc-cidr-block
  tags = {
      Name = "${var.vm-name-prefix}-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.aws-subnet-cidr-block
  # availability_zone = var.avail_zone
  tags = {
      Name = "${var.vm-name-prefix}-subnet"
  }
}

resource "aws_default_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.admin-ips
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.vm-name-prefix}-sg"
  }
}

resource "aws_internet_gateway" "igw" {
	vpc_id = aws_vpc.vpc.id

    tags = {
     Name = "${var.vm-name-prefix}-igw"
   }
}

resource "aws_default_route_table" "route-table" {
   default_route_table_id = aws_vpc.vpc.main_route_table_id

   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.igw.id
   }

   # default route, mapping VPC CIDR block to "local", created implicitly and
   # cannot be specified.

   tags = {
     Name = "${var.vm-name-prefix}-route-table"
   }
}

# Associate subnet with Route Table
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_default_route_table.route-table.id
}

resource "aws_key_pair" "debug1" {
  key_name   = "debug1"
  public_key = var.root-admin-pub-key
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
  key_name                    = aws_key_pair.debug1.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_default_security_group.sg.id]
  # user_data = element(data.template_file.node-user-datas.*.rendered, count.index)
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
