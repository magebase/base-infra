# Variables for Stripe module
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "company_name" {
  description = "Company name for billing"
  type        = string
  default     = "Magebase"
}

variable "support_email" {
  description = "Support email for customer communications"
  type        = string
}
