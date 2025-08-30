variable "region" {
  description = "AWS region for bootstrap resources"
  type        = string
  default     = "ap-southeast-1"
}

variable "account_alias" {
  description = "AWS account alias"
  type        = string
  default     = "magebase"
}

variable "create_account_alias" {
  description = "Whether to create the account alias"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "magebase-terraform-locks"
}
