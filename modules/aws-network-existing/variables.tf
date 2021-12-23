variable "default-security-group-name" {
  description = "The name of the existing default security group. This module will query AWS for a security group with this name,"
}

variable "default-vpc-name" {
  description = "The name of the existing default VPC. This module will query AWS for a VPC with this name,"
}

variable "existing-subnet-names" {
  description = "A list of subnet names that already exist in default-vpc-name"
  default     = []
  type        = list(string)
}
