
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

variable "ubuntu-image" {
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
}

variable "vm-name-prefix" {
  default = "k8s-tf"
  description = "This prefix will appear before all VM names and hostnames, ie. k8s-tf-master-0."
}