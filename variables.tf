
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

variable "worker-nodes" {
  default     = "2"
  description = "The number of worker nodes to create."
  type        = number
}

variable "ubuntu-image" {
  default = "https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
}
