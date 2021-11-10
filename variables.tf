
variable "disk-image-dir" {
  description = "This is the location on the KVM hypervisor host where all the disk images will be kept."
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

variable "worker-nodes" {
  default     = "2"
  description = "The number of worker nodes to create."
  type        = number
}

variable "ubuntu-image" {
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
}
