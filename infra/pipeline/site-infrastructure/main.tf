# Terraform configuration for Magebase infrastructure using Hetzner + k3s
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.52.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.3.0"
    }
  }
}


# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Default AWS Provider (uses management account OIDC role)
provider "aws" {
  region = "ap-southeast-1"
}

# AWS Provider (for Route53 operations) - uses management account OIDC role
provider "aws" {
  alias  = "route53"
  region = "us-east-1" # Route53 is a global service, but provider needs a region
}

# Data source to get load balancer IP from base-infrastructure
data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"
  config = {
    bucket  = "magebase-tf-state-management-ap-southeast-1"
    key     = "magebase/base-infrastructure/${var.environment}/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

# Local values
locals {
  cluster_name        = "${var.environment}-magebase"
  singapore_locations = ["sin"]            # Singapore location
  location            = var.hetzner_region # Use variable instead of hardcoded value
  account_type        = var.environment == "prod" ? "production" : "development"
  # Get the load balancer IP from base infrastructure
  cluster_ipv4 = data.terraform_remote_state.base_infrastructure.outputs.lb_ipv4
}

# Cloudflare DNS Configuration
module "cloudflare_dns" {
  source = "./modules/cloudflare"

  domain_name  = var.environment == "dev" ? "dev.${var.domain_name}" : var.domain_name
  zone_id      = var.cloudflare_zone_id
  cluster_ipv4 = local.cluster_ipv4
  cluster_ipv6 = null # IPv6 not currently available from base infrastructure

  # SES configuration
  aws_ses_account_id = var.management_account_id

  # SES DNS Records - SES is always enabled
  ses_verification_record = module.aws_ses.ses_verification_record
  ses_dkim_records        = module.aws_ses.ses_dkim_records
  ses_dkim_tokens         = module.aws_ses.dkim_tokens
  ses_spf_record          = module.aws_ses.ses_spf_record
  ses_mx_record           = module.aws_ses.ses_mx_record
}

# Cloudflare CDN Configuration for Active Storage (REMOVED - now using R2 custom domain)
# module "cloudflare_cdn" {
#   source = "./modules/cloudflare/cdn"

#   domain_name              = var.domain_name
#   active_storage_bucket    = module.cloudflare_r2.r2_bucket
#   object_storage_endpoint  = module.cloudflare_r2.r2_endpoint
#   zone_id                  = module.cloudflare_dns.zone_id
#   enable_advanced_features = false # Disable advanced features due to API token limitations
# }

# AWS SES Configuration (always enabled)
module "aws_ses" {
  source = "./modules/aws-ses"

  domain_name = var.domain_name
  environment = var.environment
  account_id  = var.management_account_id
}

# AWS SES Users (creates IAM users for each environment)
module "aws_ses_users" {
  source = "./modules/aws-ses-users"

  environment = var.environment
  account_id  = var.management_account_id
}

# Cloudflare R2 Object Storage Configuration
module "cloudflare_r2" {
  source = "./modules/cloudflare/r2"

  cluster_name          = local.cluster_name
  domain_name           = var.domain_name
  cloudflare_account_id = var.cloudflare_account_id
  environment           = var.environment
  zone_id               = var.cloudflare_zone_id
}

output "cloudflare_r2_bucket" {
  value       = module.cloudflare_r2.r2_bucket
  description = "Cloudflare R2 bucket for PostgreSQL backups"
}

output "cloudflare_r2_endpoint" {
  value       = module.cloudflare_r2.r2_endpoint
  description = "Cloudflare R2 endpoint URL"
}

output "cloudflare_account_id" {
  value       = var.cloudflare_account_id
  description = "Cloudflare Account ID being used for R2 buckets"
  sensitive   = true
}

output "cloudflare_r2_account_id" {
  value       = module.cloudflare_r2.account_id
  description = "Cloudflare Account ID from R2 module"
  sensitive   = true
}

output "cloudflare_r2_active_storage_custom_domain" {
  value       = module.cloudflare_r2.r2_active_storage_custom_domain
  description = "Custom domain for Active Storage R2 bucket"
}

output "active_storage_cdn_url" {
  value       = "https://${module.cloudflare_r2.r2_active_storage_custom_domain}"
  description = "Cloudflare CDN URL for Active Storage files"
}

# AWS Organization Outputs (moved to separate org-sso step)
# output "development_account_id" {
#   description = "AWS Account ID for the development account"
#   value       = module.organizations.development_account_id
# }

# output "production_account_id" {
#   description = "AWS Account ID for the production account"
#   value       = module.organizations.production_account_id
# }

# SSO Outputs (moved to separate org-sso step)
# output "sso_enabled" {
#   description = "Whether AWS SSO is enabled"
#   value       = module.sso.sso_enabled
# }

# output "sso_instance_arn" {
#   description = "ARN of the AWS SSO instance"
#   value       = module.sso.sso_instance_arn
# }

# SES User Outputs
output "ses_user_name" {
  description = "Name of the SES IAM user for this environment"
  value       = module.aws_ses_users.ses_user_name
}

output "ses_access_key_id" {
  description = "Access Key ID for the SES user"
  value       = module.aws_ses_users.ses_access_key_id
  sensitive   = true
}

output "ses_secret_access_key" {
  description = "Secret Access Key for the SES user"
  value       = module.aws_ses_users.ses_secret_access_key
  sensitive   = true
}

output "ses_user_arn" {
  description = "ARN of the SES IAM user"
  value       = module.aws_ses_users.ses_user_arn
}
