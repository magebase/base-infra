terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

locals {
  cluster_name = var.cluster_name
  # Remove environment from production bucket names
  bucket_name_prefix = var.environment == "prod" ? "magebase" : var.cluster_name
  custom_domain      = "cdn.${var.domain_name}"
}

# Cloudflare R2 Bucket for PostgreSQL Backups
resource "cloudflare_r2_bucket" "postgres_backups" {
  account_id = var.cloudflare_account_id
  name       = "${local.bucket_name_prefix}-postgres-backups"
}

# Cloudflare R2 Bucket for Active Storage
resource "cloudflare_r2_bucket" "active_storage" {
  account_id = var.cloudflare_account_id
  name       = "${local.bucket_name_prefix}-active-storage"
}

# Custom Domain for Active Storage R2 Bucket
resource "cloudflare_r2_custom_domain" "active_storage" {
  account_id  = var.cloudflare_account_id
  bucket_name = cloudflare_r2_bucket.active_storage.name
  domain      = local.custom_domain
  enabled     = true
  zone_id     = var.zone_id
}

# Note: Cloudflare R2 doesn't have versioning or public access blocks like S3

output "r2_bucket" {
  value       = cloudflare_r2_bucket.postgres_backups.name
  description = "Cloudflare R2 bucket for PostgreSQL backups"
}

output "r2_active_storage_bucket" {
  value       = cloudflare_r2_bucket.active_storage.name
  description = "Cloudflare R2 bucket for Active Storage"
}

output "r2_active_storage_custom_domain" {
  value       = local.custom_domain
  description = "Custom domain for Active Storage R2 bucket"
}

output "r2_endpoint" {
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  description = "Cloudflare R2 endpoint URL"
}

output "account_id" {
  value       = var.cloudflare_account_id
  description = "Cloudflare Account ID being used for R2 buckets"
}
