variable "ami" {
  description = "The AWS AMI to be used for all the nodes"
  type = string
}

variable "ec2-instance-type" {
  default = "t2.micro"
  description = "The AWS instance type to use for all nodes."
  type = string
}

variable "name-prefix" {
  default = "tf-node"
  description = "This prefix will be applied to all names created by this module."
  type = string
}

variable "num-nodes" {
  default = 1
  description = "The number of nodes to create from the given input parameters."
  type = number
}

variable "user-datas" {
  description = "A list of cloud-init configs that get applied to their corresponding node."
}

variable "subnet-ids" {
  description = "An array of subnet ids. These subnets will be round robined as the subnet to use for each node."
  type = list(string)
}

variable "security-group-ids" {
  description = "A list of security group IDs to be applied to all the nodes."
  type = list(string)
}
