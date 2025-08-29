variable "development_account_id" {
  description = "AWS Account ID for development environment"
  type        = string
}

variable "production_account_id" {
  description = "AWS Account ID for production environment"
  type        = string
}

variable "region" {
  description = "AWS region for SSO resources"
  type        = string
  default     = "ap-southeast-1"
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
