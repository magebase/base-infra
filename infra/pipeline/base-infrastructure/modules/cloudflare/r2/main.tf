terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

locals {
  cluster_name = var.cluster_name
  # Remove environment from production bucket names
  bucket_name_prefix = var.environment == "prod" ? "magebase" : var.cluster_name
}

# Cloudflare R2 Bucket for PostgreSQL Backups
resource "cloudflare_r2_bucket" "postgres_backups" {
  account_id = var.cloudflare_account_id
  name       = "${local.bucket_name_prefix}-postgres-backups"
}


output "r2_bucket" {
  value       = cloudflare_r2_bucket.postgres_backups.name
  description = "Cloudflare R2 bucket for PostgreSQL backups"
}

output "r2_endpoint" {
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  description = "Cloudflare R2 endpoint URL"
}

output "account_id" {
  value       = var.cloudflare_account_id
  description = "Cloudflare Account ID being used for R2 buckets"
}
