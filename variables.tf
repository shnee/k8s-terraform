variable "admin-ips" {
  description = "A list of ips or cidr blocks that are allowed to connect to the nodes."
  type = list(string)
}

variable "aws-ec2-instance-type" {
  default = "t2.micro"
  description = "The AWS instance type to use for all nodes."
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
# These variables are really mor like constants. Using variables improves
# readability. The defaults are manually updated. Use the aws-amis module to get
# the latest for each distro.
################################################################################

variable "amzn2-ami" {
  default     = "ami-0dd0ccab7e2801812"
  description = "The AMI to use for Amazon Linux 2."
}
variable "ubuntu-ami" {
  default = "ami-06c7d6c0987eaa46c"
  description = "The AMI to use for Ubuntu."
}
variable "centos7-ami" {
  default = "ami-00f8e2c955f7ffa9b"
  description = "The AMI to use for CentOS 7."
}
variable "centos8-ami" {
  default = "ami-057cacbfbbb471bb3"
  description = "The AMI to use for CentOS 8."
}
variable "arch-ami" {
  default = "ami-02653f06de985e3ba"
  description = "The AMI to use for Arch Linux."
}
variable "rhel7-ami" {
  default = "ami-0a509b3c2a4d05b3f"
  description = "The AMI to use for RHEL 7."
}
variable "rhel8-ami" {
  default = "ami-0d871ca8a77af2948"
  description = "The AMI to use for RHEL 8."
}

################################################################################
# Libvirt Images
# These variables are really mor like constants. Using variables improves
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
