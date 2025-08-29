# Hetzner Object Storage Module

This Terraform module creates Hetzner Object Storage buckets for PostgreSQL backups using the CloudNativePG operator.

## Features

- **MinIO Provider**: Primary S3-compatible bucket using the MinIO Terraform provider
- **AWS Provider Fallback**: Secondary bucket using AWS provider for compatibility
- **Random Bucket Names**: Unique bucket names with UUID suffixes for security
- **Private Access**: All buckets configured with private access control
- **Lifecycle Protection**: Buckets protected from accidental deletion

## Requirements

- Terraform >= 1.5.0
- MinIO provider >= 3.3.0
- AWS provider >= 5.0
- Random provider >= 3.0

## Providers

### MinIO Provider (Primary)

```hcl
provider "minio" {
  alias         = "hetzner"
  minio_server = "sin.magebase.dev"
  minio_user    = var.hetzner_object_storage_access_key
  minio_password = var.hetzner_object_storage_secret_key
  minio_region  = "sin"
  minio_ssl     = true
}
```

### AWS Provider (Fallback)

```hcl
provider "aws" {
  alias  = "hetzner-object-storage"
  region = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  endpoints {
    s3 = "https://sin.magebase.dev"
  }
}
```

## Usage

```hcl
module "hetzner_object_storage" {
  source = "./modules/hetzner/s3"

  providers = {
    minio = minio.hetzner
    aws   = aws.hetzner-object-storage
  }

  cluster_name = "my-cluster"
  hetzner_object_storage_access_key = var.hetzner_object_storage_access_key
  hetzner_object_storage_secret_key = var.hetzner_object_storage_secret_key
}
```

## Inputs

| Name                              | Description                              | Type     | Required |
| --------------------------------- | ---------------------------------------- | -------- | -------- |
| cluster_name                      | Name of the cluster for bucket naming    | `string` | Yes      |
| hetzner_object_storage_access_key | Hetzner Object Storage access key ID     | `string` | Yes      |
| hetzner_object_storage_secret_key | Hetzner Object Storage secret access key | `string` | Yes      |

## Outputs

| Name                                   | Description                          |
| -------------------------------------- | ------------------------------------ |
| hetzner_object_storage_bucket          | Primary bucket name (MinIO provider) |
| hetzner_object_storage_bucket_fallback | Fallback bucket name (AWS provider)  |
| hetzner_object_storage_endpoint        | Hetzner Object Storage endpoint URL  |

## CloudNativePG Configuration

Use the output bucket name in your CloudNativePG cluster configuration:

```yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-cluster
spec:
  backup:
    barmanObjectStore:
      destinationPath: s3://<hetzner_object_storage_bucket>/
      endpointURL: https://sin.magebase.dev
      s3Credentials:
        accessKeyId:
          name: hetzner-object-storage-credentials
          key: access_key_id
        secretAccessKey:
          name: hetzner-object-storage-credentials
          key: secret_access_key
```

## Security Notes

- All buckets are created with private access control
- Credentials are marked as sensitive in Terraform
- Buckets have lifecycle protection to prevent accidental deletion
- Use unique bucket names to avoid conflicts

## Cost Optimization

- Hetzner Object Storage is significantly cheaper than AWS S3
- No data transfer costs within Hetzner network
- Pay only for storage used
- No minimum storage requirements
