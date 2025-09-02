terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

locals {
  cluster_name = var.cluster_name
}

# Cloudflare R2 Bucket for PostgreSQL Backups
resource "random_uuid" "postgres_backup_bucket_id" {}

resource "aws_s3_bucket" "postgres_backups" {
  bucket = "${local.cluster_name}-postgres-backups-${substr(random_uuid.postgres_backup_bucket_id.result, 0, 8)}"

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the PostgreSQL backup bucket
resource "aws_s3_bucket_versioning" "postgres_backups" {
  bucket = aws_s3_bucket.postgres_backups.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Cloudflare R2 Bucket for Active Storage
resource "random_uuid" "active_storage_bucket_id" {}

resource "aws_s3_bucket" "active_storage" {
  bucket = "${local.cluster_name}-active-storage-${substr(random_uuid.active_storage_bucket_id.result, 0, 8)}"

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the Active Storage bucket
resource "aws_s3_bucket_versioning" "active_storage" {
  bucket = aws_s3_bucket.active_storage.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Public access block for security
resource "aws_s3_bucket_public_access_block" "postgres_backups" {
  bucket = aws_s3_bucket.postgres_backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "active_storage" {
  bucket = aws_s3_bucket.active_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "r2_bucket" {
  value       = aws_s3_bucket.postgres_backups.bucket
  description = "Cloudflare R2 bucket for PostgreSQL backups"
}

output "r2_active_storage_bucket" {
  value       = aws_s3_bucket.active_storage.bucket
  description = "Cloudflare R2 bucket for Active Storage"
}

output "r2_endpoint" {
  value       = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com"
  description = "Cloudflare R2 endpoint URL"
}
