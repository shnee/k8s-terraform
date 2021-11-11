variable "base-image" {
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
  description = "The base image to be used for all nodes."
}

variable "libvirt-connection-url" {
  description = "The libvirt connection URI, ie. qemu+ssh://<user>@<host>/system"
}

variable "name-prefix" {
  default = "k8s-node"
  description = "This will be a prefix for all resource names, ie. domains will be created suck as \"k8s-node-2\"."
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

variable "num-nodes" {
  description = "The number of nodes to create with this config."
}

variable "pool-name" {
  default = "default"
  description = "The name of the pool to put all disk images in."
}

variable "root-admin-passwd" {
  description = "This will be the password for the root and admin user. The format of this can by any format accepted by cloud-init's chpasswd module."
}

variable "root-admin-pub-key" {
  description = "The public key to be added to authorized_keys for the root and admin accounts."
}
