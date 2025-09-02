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

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID for R2"
  type        = string
}

variable "management_account_id" {
  description = "AWS account ID for the management account"
  type        = string
}

variable "environment_account_id" {
  description = "AWS account ID for the environment account (dev/prod)"
  type        = string
}

variable "pipeline_role_name" {
  description = "Name of the IAM role used by the CI/CD pipeline"
  type        = string
  default     = "GitHubActionsSSORole"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "magebase.dev"
}

variable "cluster_ipv4" {
  description = "IPv4 address of the cluster load balancer from base infrastructure"
  type        = string
  default     = "127.0.0.1"
}

# variable "secret_key_base" {
#   description = "Rails secret key base"
#   type        = string
#   sensitive   = true
# }

# variable "ruby_llm_api_key" {
#   description = "RubyLLM API key"
#   type        = string
#   sensitive   = true
# }

variable "aws_ses_access_key_id" {
  description = "AWS SES access key ID"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_ses_secret_access_key" {
  description = "AWS SES secret access key"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hetzner_object_storage_access_key" {
  description = "Hetzner Object Storage access key ID (deprecated - using Cloudflare R2)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hetzner_object_storage_secret_key" {
  description = "Hetzner Object Storage secret access key (deprecated - using Cloudflare R2)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "hetzner_object_storage_endpoint" {
  description = "Hetzner Object Storage endpoint URL (deprecated - using Cloudflare R2)"
  type        = string
  default     = ""
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
  default     = ""
}

variable "stripe_webhook_secret" {
  description = "Stripe webhook secret for validating webhook signatures"
  type        = string
  sensitive   = true
  default     = ""
}

variable "company_name" {
  description = "Company name for billing and legal purposes"
  type        = string
  default     = "Magebase"
}

variable "support_email" {
  description = "Support email address for customer communications"
  type        = string
  default     = "support@magebase.dev"
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

variable "ssh_private_key" {
  description = "SSH private key for accessing k3s nodes"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for accessing k3s nodes"
  type        = string
  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521|ssh-dss|sk-ssh-ed25519@openssh.com|sk-ssh-ed25519|sk-ecdsa-sha2-nistp256|sk-ecdsa-sha2-nistp384|sk-ecdsa-sha2-nistp521)", var.ssh_public_key))
    error_message = "SSH public key must be one of the supported types: ssh-rsa, ssh-ed25519, ecdsa-sha2-nistp256, ecdsa-sha2-nistp384, ecdsa-sha2-nistp521, ssh-dss, sk-ssh-ed25519@openssh.com, sk-ssh-ed25519, sk-ecdsa-sha2-nistp256, sk-ecdsa-sha2-nistp384, sk-ecdsa-sha2-nistp521"
  }
}
