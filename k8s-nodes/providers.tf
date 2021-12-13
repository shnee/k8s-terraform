
provider "aws" {
  region = "us-gov-west-1"
}


terraform {
  required_version = ">= 1.0.8"

    backend "s3" {
      
      bucket            = "mss-terraform-state"
      key               = "global/s3/terraform.tfstate"
      region            = "us-gov-west-1"
      
      dynamodb_table    = "mss-terraform-state-lock"
      encrypt           = true

  }
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.11"
    }
  }
}





##
#S3 bucket create to hold our TFState file so we can all share env settings
resource "aws_s3_bucket" "terraform_state" {
    bucket = "mss-terraform-state"

    # enable versioning for the state files 
    versioning {
        enabled = true
    }

    #enable server-side encryption
    server_side_encryption_configuration {
      
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
              }
          }
        } 
}

##
# no sql database used so that we can lock the TFstate file in the S3 bucket to ensure two people 
# are not running a terraform command at the same time 
resource "aws_dynamodb_table" "terraform_locks" {
    name            = "mss-terraform-state-lock"
    billing_mode    = "PAY_PER_REQUEST"
    hash_key        = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }


}


##
# output variable to give details on the s3 bucket created
#TODO: move to output.tf
output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}