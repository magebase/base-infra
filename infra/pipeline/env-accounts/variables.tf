variable "region" {
  description = "AWS region for the accounts"
  type        = string
  default     = "us-east-1"
}

variable "development_email" {
  description = "Email address for development AWS account"
  type        = string
}

variable "production_email" {
  description = "Email address for production AWS account"
  type        = string
}

variable "development_account_id" {
  description = "AWS Account ID for the development account"
  type        = string
  default     = ""
}

variable "production_account_id" {
  description = "AWS Account ID for the production account"
  type        = string
  default     = ""
}
