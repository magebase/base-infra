terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region

  # Use the default credentials chain
  # This will use AWS credentials from environment variables, shared credentials file, or IAM roles
}

# Create S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.account_alias}-tf-state-${var.region}-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = "magebase"
    ManagedBy   = "terraform"
    Purpose     = "terraform-state-management"
  }
}

# Generate a random suffix for the bucket name to avoid conflicts
resource "random_string" "bucket_suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block public access to the bucket
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 bucket policy to allow access from GitHub Actions SSO role
# Note: This will be created after SSO roles are set up
# resource "aws_s3_bucket_policy" "terraform_state_policy" {
#   bucket = aws_s3_bucket.terraform_state.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid       = "AllowGitHubActionsSSOAccess"
#         Effect    = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/GitHubActionsSESRole"
#         }
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           aws_s3_bucket.terraform_state.arn,
#           "${aws_s3_bucket.terraform_state.arn}/*"
#         ]
#       },
#       {
#         Sid       = "AllowCurrentUserAccess"
#         Effect    = "Allow"
#         Principal = {
#           AWS = data.aws_caller_identity.current.arn
#         }
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           aws_s3_bucket.terraform_state.arn,
#           "${aws_s3_bucket.terraform_state.arn}/*"
#         ]
#       }
#     ]
#   })
# }

# Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.dynamodb_table_name}-${random_string.bucket_suffix.result}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = var.environment
    Project     = "magebase"
    ManagedBy   = "terraform"
    Purpose     = "terraform-state-management"
  }

  # Enable point-in-time recovery
  point_in_time_recovery {
    enabled = true
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled = true
  }
}

# Create IAM account alias
resource "aws_iam_account_alias" "alias" {
  count = var.create_account_alias ? 1 : 0
  account_alias = var.account_alias
}

# Data source to get current account ID for bucket policy
data "aws_caller_identity" "current" {}

# Outputs for use in main Terraform configuration
output "state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table" {
  description = "Name of the DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.arn
}
