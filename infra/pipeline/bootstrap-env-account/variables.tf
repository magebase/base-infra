variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_alias" {
  description = "IAM account alias"
  type        = string
  default     = "magebase"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'"
  }
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "magebase-terraform-locks"
}

variable "create_account_alias" {
  description = "Whether to create IAM account alias"
  type        = bool
  default     = true
}
