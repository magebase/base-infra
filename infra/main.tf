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
  api_token = var.cloudflare_api_token
}

# AWS Provider (for SES only)
provider "aws" {
  alias  = "ses"
  region = "ap-southeast-1" # Singapore region for SES
  assume_role {
    role_arn = "arn:aws:iam::${var.aws_ses_account_id}:role/SESManagerRole"
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
  source = "./modules/cloudflare"

  domain_name  = var.domain_name
  cluster_ipv4 = module.kube-hetzner.ingress_public_ipv4
  cluster_ipv6 = module.kube-hetzner.ingress_public_ipv6
}

# Cloudflare CDN Configuration for Active Storage
module "cloudflare_cdn" {
  source = "./modules/cloudflare/cdn"

  domain_name             = var.domain_name
  active_storage_bucket   = module.hetzner_object_storage.hetzner_active_storage_bucket
  object_storage_endpoint = module.hetzner_object_storage.hetzner_object_storage_endpoint
  zone_id                 = module.cloudflare_dns.zone_id
}

# AWS SES Configuration (kept from old infrastructure)
module "aws_ses" {
  source = "./modules/aws-ses"
  providers = {
    aws = aws.ses
  }

  domain_name = var.domain_name
  environment = var.environment
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
  value       = module.cloudflare_cdn.active_storage_cdn_url
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
