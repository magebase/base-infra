# Terraform configuration for Magebase infrastructure using Hetzner + k3s
terraform {
  required_version = ">= 1.8.0"

    # Backend configuration using environment-specific S3 bucket created by bootstrap-env-account
  backend "s3" {
    bucket      = "magebase-tf-state-bootstrap-dev-ap-southeast-1"
    key         = "magebase/site-infrastructure/dev/terraform.tfstate"
    region      = "ap-southeast-1"
    encrypt     = true
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.52.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
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

# AWS Provider (for Route53 operations) - assumes the respective account's GitHubActionsSSORole
provider "aws" {
  alias  = "route53"
  region = "us-east-1" # Route53 is a global service, but provider needs a region

  assume_role {
    role_arn = local.github_actions_role_arn
  }
}

# IAM Role for SES Management (created outside module to avoid cycle)
resource "aws_iam_role" "ses_manager" {
  provider = aws.route53
  name     = "SESManagerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.aws_ses_account_id}:role/GitHubActionsSSORole",
            "arn:aws:sts::${var.aws_ses_account_id}:assumed-role/GitHubActionsSSORole/*"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "SES Management"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      assume_role_policy, # Allow manual changes to the policy
    ]
  }
}

# IAM Policy for SES Management
resource "aws_iam_role_policy" "ses_manager_policy" {
  provider = aws.route53
  name     = "SESManagerPolicy"
  role     = aws_iam_role.ses_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:GetChange",
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      policy, # Allow manual changes to the policy
    ]
  }
}

# AWS Provider (for SES only) - now uses the respective account's GitHubActionsSSORole
provider "aws" {
  alias  = "ses"
  region = "ap-southeast-1" # Singapore region for SES

  assume_role {
    role_arn = local.github_actions_role_arn
  }
}

# Data source for base infrastructure remote state
data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"
  config = {
    bucket         = "magebase-tf-state-bootstrap-ap-southeast-1"
    key            = "magebase/base-infrastructure/${var.environment}/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "magebase-terraform-locks-bootstrap"
    encrypt        = true
  }
}

# Data source for org-sso remote state to get GitHubActionsSSORole ARN
data "terraform_remote_state" "org_sso" {
  backend = "s3"
  config = {
    bucket      = "magebase-tf-state-bootstrap-ap-southeast-1"
    key         = "magebase/org-sso/terraform.tfstate"
    region      = "ap-southeast-1"
    encrypt     = true
  }
}

# Local values
locals {
  cluster_name        = "${var.environment}-magebase"
  singapore_locations = ["sin"] # Singapore location
  location            = "fsn1"  # Falkenstein for all environments
  account_type        = var.environment == "prod" ? "production" : "development"
  github_actions_role_arn = lookup(
    data.terraform_remote_state.org_sso.outputs.github_actions_sso_roles,
    local.account_type,
    ""
  ).arn
}

# Cloudflare DNS Configuration
module "cloudflare_dns" {
  source = "./modules/cloudflare"

  domain_name  = var.domain_name
  cluster_ipv4 = try(data.terraform_remote_state.base_infrastructure.outputs.lb_ipv4, "127.0.0.1")
  cluster_ipv6 = null # IPv6 not currently available from base infrastructure

  # SES configuration
  aws_ses_account_id = var.aws_ses_account_id

  # SES DNS Records - SES is always enabled
  ses_verification_record = module.aws_ses.ses_verification_record
  ses_dkim_records        = [] # Always pass empty list to avoid count dependency issues
  ses_spf_record          = module.aws_ses.ses_spf_record
  ses_mx_record           = module.aws_ses.ses_mx_record
}

# Cloudflare CDN Configuration for Active Storage - commented out due to module issues
# module "cloudflare_cdn" {
#   count = var.cloudflare_api_token != "" && var.cloudflare_api_token != "dummy_token_for_validation" ? 1 : 0
#
#   source = "./modules/cloudflare/cdn"
#
#   domain_name             = var.domain_name
#   active_storage_bucket   = module.hetzner_object_storage.hetzner_active_storage_bucket
#   object_storage_endpoint = module.hetzner_object_storage.hetzner_object_storage_endpoint
#   zone_id                 = module.cloudflare_dns.zone_id
# }

# AWS SES Configuration (always enabled)
module "aws_ses" {
  source = "./modules/aws-ses"
  providers = {
    aws = aws.ses
  }

  domain_name          = var.domain_name
  environment          = var.environment
  account_id           = var.aws_ses_account_id
  ses_manager_role_arn = aws_iam_role.ses_manager.arn
}

# MinIO Provider for Hetzner Object Storage (recommended approach)
provider "minio" {
  alias          = "hetzner"
  minio_server   = var.hetzner_object_storage_endpoint != "" ? var.hetzner_object_storage_endpoint : "fsn1.${var.domain_name}"
  minio_user     = var.hetzner_object_storage_access_key
  minio_password = var.hetzner_object_storage_secret_key
  minio_region   = "fsn1"
  minio_ssl      = true
}

# AWS Provider for Hetzner Object Storage (S3-compatible)
provider "aws" {
  alias                       = "hetzner-object-storage"
  region                      = "us-east-1" # Hetzner Object Storage doesn't use regions, but AWS provider requires one
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  endpoints {
    s3 = var.hetzner_object_storage_endpoint != "" ? "https://${var.hetzner_object_storage_endpoint}" : "https://fsn1.${var.domain_name}"
  }

  assume_role {
    role_arn = local.github_actions_role_arn
  }
}

# Hetzner Object Storage Configuration
module "hetzner_object_storage" {
  source = "./modules/hetzner/s3"

  providers = {
    minio = minio.hetzner
    aws   = aws.hetzner-object-storage
  }

  cluster_name                      = local.cluster_name
  domain_name                       = var.domain_name
  location                          = local.location
  hetzner_object_storage_access_key = var.hetzner_object_storage_access_key
  hetzner_object_storage_secret_key = var.hetzner_object_storage_secret_key
  hetzner_object_storage_endpoint   = var.hetzner_object_storage_endpoint
}

output "hetzner_object_storage_bucket" {
  value       = module.hetzner_object_storage.hetzner_object_storage_bucket
  description = "Hetzner Object Storage bucket for PostgreSQL backups (MinIO provider)"
}

output "hetzner_object_storage_bucket_fallback" {
  value       = module.hetzner_object_storage.hetzner_object_storage_bucket_fallback
  description = "Hetzner Object Storage bucket for PostgreSQL backups (AWS provider fallback)"
}

output "hetzner_object_storage_endpoint" {
  value       = module.hetzner_object_storage.hetzner_object_storage_endpoint
  description = "Hetzner Object Storage endpoint URL"
}

output "active_storage_cdn_url" {
  value       = "https://cdn.${var.domain_name}"
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
