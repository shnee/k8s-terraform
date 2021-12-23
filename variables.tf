variable "admin-ips" {
  default = ["0.0.0.0/0"]
  description = "A list of ips or cidr blocks that are allowed to connect to the nodes."
  type = list(string)
}

variable "aws-existing-sg-name" {
  default = "change-me-if-using-aws-network-existing"
  description = "The name of the existing security group when using aws-network-existing."
}

variable "aws-existing-vpc-name" {
  default = "change-me-if-using-aws-network-existing"
  description = "The name of the existing VPC when using aws-network-existing."
}

variable "aws-existing-subnet-names" {
  description = "A list of subnet names that already exist in aws-existing-vpc-name"
  default     = []
  type        = list(string)
}

variable "aws-region" {
  default = "us-east-1"
  description = "The AWS region to use."
}

variable "aws-subnet-cidr-block" {
  default = "10.0.1.0/24"
  description = "The address space to be used for this subnet."
}

variable "aws-vpc-cidr-block" {
  default = "10.0.0.0/16"
  description = "The address space to be used for the VPC that all the AWS nodes will be in."
}

variable "disk-image-dir" {
  description = "This is the location on the KVM hypervisor host where all the disk images will be kept."
}

variable "disk-image-pool-name" {
  default = "k8s-tf-images"
  description = "The name of the disk pool where all the images will be kept."
}

variable "libvirt-connection-url" {
  default = "nobody@localhost"
  description = "The libvirt connection URI, ie. qemu+ssh://<user>@<host>/system"
}

variable "libvirt-network-name" {
  default = "default"
  description = "The name of a pre-existing libvirt virtual-network."
}

variable "libvirt-node-disk-size" {
  default = 4294967296
  description = "The size of the disk to be used for libvirt nodes. (in bytes)"
}

variable "node-memory" {
  default     = "2048"
  description = "The amount of memory to be used for all the nodes."
  type        = number
}

variable "node-vcpus" {
  default     = "2"
  description = "The amount of vcpus to be used for all the nodes."
  type        = number
}

variable "root-admin-passwd" {
  description = "This will be the password for the root and admin user. The format of this can by any format accepted by cloud-init's chpasswd module."
}

variable "root-admin-pub-key" {
  description = "The public key to be added to authorized_keys for the root and admin accounts."
}

variable "master-nodes" {
  default     = 1
  description = "The number of master nodes to create."
  type        = number
}

variable "worker-nodes" {
  default     = 2
  description = "The number of worker nodes to create."
  type        = number
}

variable "base-image" {
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
}

variable "vm-name-prefix" {
  default = "k8s-tf"
  description = "This prefix will appear before all VM names and hostnames, ie. k8s-tf-master-0."
}

################################################################################
# AWS AMI vars
# These variables are really more like constants. Using variables improves
# readability. The defaults are manually updated. Use the aws-amis module to get
# the latest for each distro.
################################################################################

variable "amzn2-ami" {
  # us-east-2
  # default     = "ami-0dd0ccab7e2801812"
  # us-gov-west-1
  default     = "ami-098bf51d9a35299f0"
  description = "The AMI to use for Amazon Linux 2."
}
variable "ubuntu-ami" {
  # us-east-2
  # default = "ami-06c7d6c0987eaa46c"
  # us-gov-west-1
  default = "ami-087ee83c8de303181"
  description = "The AMI to use for Ubuntu."
}
variable "centos7-ami" {
  # us-east-2
  default = "ami-00f8e2c955f7ffa9b"
  description = "The AMI to use for CentOS 7."
}
variable "centos8-ami" {
  # us-east-2
  default = "ami-057cacbfbbb471bb3"
  description = "The AMI to use for CentOS 8."
}
variable "arch-ami" {
  # us-east-2
  default = "ami-02653f06de985e3ba"
  description = "The AMI to use for Arch Linux."
}
variable "rhel7-ami" {
  # us-east-2
  # default = "ami-0a509b3c2a4d05b3f"
  # us-gov-west-1
  default = "ami-04ccdf5793086ea95"
  description = "The AMI to use for RHEL 7."
}
variable "rhel8-ami" {
  # us-east-2
  # default = "ami-0d871ca8a77af2948"
  # us-gov-west-1
  default = "ami-0b1f10cd1cd107dd2"
  description = "The AMI to use for RHEL 8."
}

################################################################################
# AWS EC2 types.
# These variables are really more like constants. Using variables improves
# readability.
################################################################################

variable "t2-micro-1gib-1vcpu" {
  description = "t2.micro EC2 instance with 1 GiB mem and 1 vCPU."
  default = "t2.micro"
}

variable "t2-medium-4gib-2vcpu" {
  description = "t2.medium EC2 instance with 4 GiB mem and 2 vCPUs."
  default = "t2.medium"
}

variable "t2-large-8gib-2vcpu" {
  description = "t2.large EC2 instance with 8 GiB mem and 2 vCPUs."
  default = "t2.large"
}

variable "t2-xlarge-16gib-4vcpu" {
  description = "t2.xlarge EC2 instance with 16 GiB mem and 4 vCPUs."
  default = "t2.xlarge"
}

################################################################################
# Libvirt Images
# These variables are really more like constants. Using variables improves
# readability. The defaults are manually updated.
################################################################################

variable "ubuntu-img" {
  default     = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  description = "The libvirt image tp use for Ubuntu."
}

variable "centos7-img" {
  # Latest as of 2021-12-06.
  default = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2111.qcow2"
  description = "The libvirt image tp use for CentOS 7."
}

variable "centos8-img" {
  default = "https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.4.2105-20210603.0.x86_64.qcow2"
  description = "The libvirt image tp use for CentOS 8."
}
