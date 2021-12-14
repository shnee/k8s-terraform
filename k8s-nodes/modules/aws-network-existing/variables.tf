variable "default-vpc-name" {
  description = "The name of the existing default VPC. This module will query AWS for a VPC with this name,"
  default = "Managed VPC"
}
