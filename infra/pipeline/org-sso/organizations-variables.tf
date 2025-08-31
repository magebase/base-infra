variable "development_email" {
  description = "Email address for development AWS account"
  type        = string
}

variable "production_email" {
  description = "Email address for production AWS account"
  type        = string
}

variable "region" {
  description = "AWS region for Organizations (must be us-east-1)"
  type        = string
  default     = "us-east-1"
}

variable "development_account_id" {
  description = "AWS Account ID for the development account"
  type        = string
}

variable "production_account_id" {
  description = "AWS Account ID for the production account"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "management"
    Project     = "magebase"
    ManagedBy   = "terraform"
  }
}
