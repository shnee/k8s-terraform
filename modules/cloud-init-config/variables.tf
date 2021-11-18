variable "cloud-init-template" {
  default     = "../../cloud_init.cfg"
  description = "The path to the cloud-init config template."
  type        = string
}

variable "hostname-prefix" {
  description = "This prefix wil be applied as a prefix for the hostnames."
}

variable "num" {
  description = "The number of user-datas to create with these parameters."
}

variable "root-admin-passwd" {
  description = "This value will be substituted for any occurence of 'admin-password' in the cloud-init config template."
}

variable "root-admin-pub-key" {
  description = "This value will be substituted for any occurence of 'admin-pub-key' in the cloud-init config template."
}

