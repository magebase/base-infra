# Terraform configuration for Magebase infrastructure using Hetzner + k3s
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.51.0"
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

# AWS Organizations and SSO Configuration
# This must run first to create accounts before SSO assignments
module "organizations" {
  source = "./organizations"

  development_email = var.development_email
  production_email  = var.production_email
  region            = "us-east-1" # Organizations must be in us-east-1
}

# AWS SSO Configuration (depends on organizations module)
module "sso" {
  source = "./sso"

  development_account_id = module.organizations.development_account_id
  production_account_id  = module.organizations.production_account_id
  region                 = "ap-southeast-1" # SSO region
}

# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : "dummy_token_for_validation_12345678901234567890"
}

# AWS Provider (for Route53 operations)
provider "aws" {
  alias  = "route53"
  region = "us-east-1" # Route53 is a global service, but provider needs a region
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_ses_account_id}:role/GitHubActionsSSORole"
  }
}

# IAM Role for SES Management (created outside module to avoid cycle)
resource "aws_iam_role" "ses_manager" {
  count = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" ? 1 : 0

  provider = aws.route53
  name     = "SESManagerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_ses_account_id}:role/GitHubActionsSSORole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "SES Management"
  }
}

# IAM Policy for SES Management
resource "aws_iam_role_policy" "ses_manager_policy" {
  count = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" ? 1 : 0

  provider = aws.route53
  name     = "SESManagerPolicy"
  role     = aws_iam_role.ses_manager[0].id

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
}

# AWS Provider (for SES only) - now uses the role created above
provider "aws" {
  alias  = "ses"
  region = "ap-southeast-1" # Singapore region for SES
  assume_role {
    role_arn = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" ? aws_iam_role.ses_manager[0].arn : "arn:aws:iam::123456789012:role/DummyRole"
  }
}

# Local values
locals {
  cluster_name        = "${var.environment}-magebase"
  singapore_locations = ["sin"] # Singapore location
  location            = "sin"   # Singapore for all environments
}

# Cloudflare DNS Configuration
module "cloudflare_dns" {
  count = var.cloudflare_api_token != "" && var.cloudflare_api_token != "dummy_token_for_validation" ? 1 : 0

  source = "./modules/cloudflare"

  domain_name  = var.domain_name
  cluster_ipv4 = module.kube-hetzner.ingress_public_ipv4
  cluster_ipv6 = module.kube-hetzner.ingress_public_ipv6
}

# Cloudflare CDN Configuration for Active Storage
module "cloudflare_cdn" {
  count = var.cloudflare_api_token != "" && var.cloudflare_api_token != "dummy_token_for_validation" ? 1 : 0

  source = "./modules/cloudflare/cdn"

  domain_name             = var.domain_name
  active_storage_bucket   = module.hetzner_object_storage.hetzner_active_storage_bucket
  object_storage_endpoint = module.hetzner_object_storage.hetzner_object_storage_endpoint
  zone_id                 = module.cloudflare_dns[0].zone_id
}

# AWS SES Configuration (conditional - requires proper IAM role setup)
module "aws_ses" {
  count = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" ? 1 : 0

  source = "./modules/aws-ses"
  providers = {
    aws        = aws.ses
    aws.route53 = aws.route53
  }

  domain_name          = var.domain_name
  environment          = var.environment
  account_id           = var.aws_ses_account_id
  ses_manager_role_arn = aws_iam_role.ses_manager[0].arn
}

# MinIO Provider for Hetzner Object Storage (recommended approach)
provider "minio" {
  alias          = "hetzner"
  minio_server   = "sin.${var.domain_name}"
  minio_user     = var.hetzner_object_storage_access_key
  minio_password = var.hetzner_object_storage_secret_key
  minio_region   = "sin"
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
    s3 = "https://sin.${var.domain_name}"
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
  hetzner_object_storage_access_key = var.hetzner_object_storage_access_key
  hetzner_object_storage_secret_key = var.hetzner_object_storage_secret_key
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
  value       = length(module.cloudflare_cdn) > 0 ? module.cloudflare_cdn[0].active_storage_cdn_url : null
  description = "Cloudflare CDN URL for Active Storage files"
}

# AWS Organization Outputs
output "development_account_id" {
  description = "AWS Account ID for the development account"
  value       = module.organizations.development_account_id
}

output "production_account_id" {
  description = "AWS Account ID for the production account"
  value       = module.organizations.production_account_id
}

# SSO Outputs
output "sso_enabled" {
  description = "Whether AWS SSO is enabled"
  value       = module.sso.sso_enabled
}

output "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  value       = module.sso.sso_instance_arn
}
