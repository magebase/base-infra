variable "region" {
  description = "AWS region for SSO resources"
  type        = string
  default     = "ap-southeast-1"
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
