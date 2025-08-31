terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.3.0"
    }
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
  cluster_name            = var.cluster_name
  object_storage_endpoint = "https://${var.location}.${var.domain_name}"
}

# Hetzner Object Storage Bucket for PostgreSQL Backups using MinIO provider
resource "random_uuid" "postgres_backup_bucket_id" {}

resource "minio_s3_bucket" "postgres_backups" {
  bucket         = "${local.cluster_name}-postgres-backups-${substr(random_uuid.postgres_backup_bucket_id.result, 0, 8)}"
  acl            = "private"
  object_locking = false

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the PostgreSQL backup bucket
resource "minio_s3_bucket_versioning" "postgres_backups" {
  bucket = minio_s3_bucket.postgres_backups.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

# Fallback: AWS provider configuration for Hetzner Object Storage
resource "aws_s3_bucket" "postgres_backups" {
  bucket = "${local.cluster_name}-postgres-backups-fallback"

  lifecycle {
    prevent_destroy = true
  }
}

output "hetzner_object_storage_bucket" {
  value       = minio_s3_bucket.postgres_backups.bucket
  description = "Hetzner Object Storage bucket for PostgreSQL backups (MinIO provider)"
}

output "hetzner_object_storage_bucket_fallback" {
  value       = aws_s3_bucket.postgres_backups.bucket
  description = "Hetzner Object Storage bucket for PostgreSQL backups (AWS provider fallback)"
}

output "hetzner_object_storage_endpoint" {
  value       = local.object_storage_endpoint
  description = "Hetzner Object Storage endpoint URL"
}