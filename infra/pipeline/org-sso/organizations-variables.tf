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
