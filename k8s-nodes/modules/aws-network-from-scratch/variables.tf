variable "admin-ips" {
  description = "A list of ips or cidr blocks that are allowed to connect to the nodes."
  type = list(string)
}

variable "name-prefix" {
  default = "tf"
  description = "This prefix will be used in all the names of the resources creates in our AWS network."
  type = string
}

variable "subnet-cidr-block" {
  default = "10.0.1.0/24"
  description = "The address space to be used for this subnet."
  type = string
}

variable "vpc-cidr-block" {
  default = "10.0.0.0/16"
  description = "The address space to be used for out networks VPC."
  type = string
}

