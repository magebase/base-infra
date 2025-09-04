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

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
}

variable "cloudflare_r2_access_key_id" {
  description = "Cloudflare R2 Access Key ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_r2_secret_access_key" {
  description = "Cloudflare R2 Secret Access Key"
  type        = string
  sensitive   = true
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

# cluster_ipv4 is now obtained from base-infrastructure remote state
# variable "cluster_ipv4" {
#   description = "IPv4 address of the cluster load balancer from base infrastructure"
#   type        = string
#   default     = "127.0.0.1"
# }

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

variable "hetzner_region" {
  description = "Hetzner Cloud region/datacenter location"
  type        = string
  default     = "fsn1"
  validation {
    condition     = contains(["fsn1", "nbg1", "hel1", "ash", "sin"], var.hetzner_region)
    error_message = "Hetzner region must be one of: fsn1 (Falkenstein), nbg1 (Nuremberg), hel1 (Helsinki), ash (Ashburn), sin (Singapore)"
  }
}

variable "cloudflare_region" {
  description = "Cloudflare region for operations"
  type        = string
  default     = "EU"
  validation {
    condition     = contains(["EU", "US"], var.cloudflare_region)
    error_message = "Cloudflare region must be either 'EU' or 'US'"
  }
}

# Kubernetes Configuration
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file for accessing the k3s cluster"
  type        = string
  default     = "../../../k3s.yaml"
}

variable "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  type        = string
  default     = "argocd"
}

variable "argocd_repo_url" {
  description = "Git repository URL containing ArgoCD applications"
  type        = string
  default     = "https://github.com/magebase/site"
}

variable "argocd_repo_branch" {
  description = "Branch to use for ArgoCD applications"
  type        = string
  default     = "main"
}

variable "argocd_target_revision" {
  description = "Target revision for ArgoCD applications"
  type        = string
  default     = "HEAD"
}
