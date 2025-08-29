# Hetzner Object Storage Bucket for Rails Active Storage
resource "random_uuid" "active_storage_bucket_id" {}

resource "minio_s3_bucket" "active_storage" {
  bucket         = "${local.cluster_name}-active-storage-${substr(random_uuid.active_storage_bucket_id.result, 0, 8)}"
  acl            = "private"
  object_locking = false

  lifecycle {
    prevent_destroy = true
  }
}

# Enable versioning for the Active Storage bucket
resource "minio_s3_bucket_versioning" "active_storage" {
  bucket = minio_s3_bucket.active_storage.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

output "hetzner_active_storage_bucket" {
  value       = minio_s3_bucket.active_storage.bucket
  description = "Hetzner Object Storage bucket for Rails Active Storage (MinIO provider)"
}
