# Variables for Terraform configuration
variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'"
  }
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "aws_ses_account_id" {
  description = "AWS account ID for SES"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "magebase.dev"
}

variable "database_url" {
  description = "Database URL"
  type        = string
  sensitive   = true
}

variable "cache_database_url" {
  description = "Cache database URL (SolidCache uses PostgreSQL)"
  type        = string
  sensitive   = true
}

variable "secret_key_base" {
  description = "Rails secret key base"
  type        = string
  sensitive   = true
}

variable "ruby_llm_api_key" {
  description = "RubyLLM API key"
  type        = string
  sensitive   = true
}

variable "aws_ses_access_key_id" {
  description = "AWS SES access key ID"
  type        = string
  sensitive   = true
}

variable "aws_ses_secret_access_key" {
  description = "AWS SES secret access key"
  type        = string
  sensitive   = true
}

variable "hetzner_object_storage_access_key" {
  description = "Hetzner Object Storage access key ID"
  type        = string
  sensitive   = true
}

variable "hetzner_object_storage_secret_key" {
  description = "Hetzner Object Storage secret access key"
  type        = string
  sensitive   = true
}

variable "docker_image" {
  description = "Docker image for deployment"
  type        = string
  default     = "magebase/site:latest"
}

variable "stripe_api_key" {
  description = "Stripe API key for managing billing infrastructure"
  type        = string
  sensitive   = true
}

variable "stripe_webhook_secret" {
  description = "Stripe webhook secret for validating webhook signatures"
  type        = string
  sensitive   = true
}

variable "development_email" {
  description = "Email address for development AWS account"
  type        = string
  default     = "magebase.dev+development@gmail.com"
}

variable "production_email" {
  description = "Email address for production AWS account"
  type        = string
  default     = "magebase.dev+production@gmail.com"
}
