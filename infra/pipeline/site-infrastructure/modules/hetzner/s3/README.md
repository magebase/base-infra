          key: access_key_id
          key: secret_access_key
          name: hetzner-object-storage-credentials
          name: hetzner-object-storage-credentials
        accessKeyId:
        secretAccessKey:
      destinationPath: s3://<hetzner_object_storage_bucket>/
      endpointURL: https://sin.magebase.dev
      s3Credentials:
    aws   = aws.hetzner-object-storage
    barmanObjectStore:
    minio = minio.hetzner
    s3 = "https://sin.magebase.dev"
  This Terraform module creates Hetzner Object Storage buckets for PostgreSQL backups using the CloudNativePG operator.
  Use the output bucket name in your CloudNativePG cluster configuration:
# Hetzner Object Storage Module
## CloudNativePG Configuration
## Cost Optimization
## Features
## Inputs
## Outputs
## Providers
## Requirements
## Security Notes
## Usage
### AWS Provider (Fallback)
### MinIO Provider (Primary)
- **AWS Provider Fallback**: Secondary bucket using AWS provider for compatibility
- **Lifecycle Protection**: Buckets protected from accidental deletion
- **MinIO Provider**: Primary S3-compatible bucket using the MinIO Terraform provider
- **Private Access**: All buckets configured with private access control
- **Random Bucket Names**: Unique bucket names with UUID suffixes for security
- AWS provider >= 5.0
- All buckets are created with private access control
- Buckets have lifecycle protection to prevent accidental deletion
- Credentials are marked as sensitive in Terraform
- Hetzner Object Storage is significantly cheaper than AWS S3
- MinIO provider >= 3.3.0
- No data transfer costs within Hetzner network
- No minimum storage requirements
- Pay only for storage used
- Random provider >= 3.0
- Terraform >= 1.5.0
- Use unique bucket names to avoid conflicts
```
```
```
```
```
```
```
```
````
````hcl
```hcl
```hcl
```yaml
alias = "hetzner"
alias = "hetzner-object-storage"
apiVersion: postgresql.cnpg.io/v1
backup:
cluster_name = "my-cluster"
endpoints {
hetzner_object_storage_access_key = var.hetzner_object_storage_access_key
hetzner_object_storage_secret_key = var.hetzner_object_storage_secret_key
kind: Cluster
metadata:
minio_password = var.hetzner_object_storage_secret_key
minio_region = "sin"
minio_server = "sin.magebase.dev"
minio_ssl = true
minio_user = var.hetzner_object_storage_access_key
module "hetzner_object_storage" {
name: postgres-cluster
provider "aws" {
provider "minio" {
providers = {
region = "us-east-1"
skip_credentials_validation = true
skip_metadata_api_check = true
skip_region_validation = true
skip_requesting_account_id = true
source = "./modules/hetzner/s3"
spec:
| --------------------------------- | ---------------------------------------- | -------- | -------- |
| -------------------------------------- | ------------------------------------ |
| Name                                   | Description                          |
| Name                              | Description                              | Type     | Required |
| cluster_name                      | Name of the cluster for bucket naming    | `string` | Yes      |
| hetzner_object_storage_access_key | Hetzner Object Storage access key ID     | `string` | Yes      |
| hetzner_object_storage_bucket          | Primary bucket name (MinIO provider) |
| hetzner_object_storage_bucket_fallback | Fallback bucket name (AWS provider)  |
| hetzner_object_storage_endpoint        | Hetzner Object Storage endpoint URL  |
| hetzner_object_storage_secret_key | Hetzner Object Storage secret access key | `string` | Yes      |
}
}
}
}
}
