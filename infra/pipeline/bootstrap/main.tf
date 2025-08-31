terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.43.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Bootstrap module for Terraform state management
module "bootstrap" {
  source  = "trussworks/bootstrap/aws"
  version = "7.0.0"

  region        = var.region
  account_alias = var.account_alias

  # Enable additional security features
  dynamodb_point_in_time_recovery = true
  enable_s3_public_access_block   = true
  manage_account_alias            = var.create_account_alias
}

# Outputs for use in main Terraform configuration
output "state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.bootstrap.state_bucket
}

output "dynamodb_table" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = module.bootstrap.dynamodb_table
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = "arn:aws:s3:::${module.bootstrap.state_bucket}"
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${module.bootstrap.dynamodb_table}"
}

# Data source to get current account ID
data "aws_caller_identity" "current" {}
