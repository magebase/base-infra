# Terraform State Management - Bootstrap Setup

This directory contains the bootstrap configuration for setting up Terraform state management with AWS S3 and DynamoDB.

## Overview

This setup implements a "bootstrapping" approach for Terraform state management, where we create the backend resources (S3 bucket and DynamoDB table) in a separate Terraform configuration before using them in the main configuration.

## Architecture

- **S3 Bucket**: `magebase-tf-state-ap-southeast-1` - Stores Terraform state files
- **DynamoDB Table**: `magebase-terraform-locks` - Provides state locking to prevent concurrent modifications
- **IAM Account Alias**: `magebase` - Friendly account identifier

## Bootstrap Process

### Step 1: Create Backend Resources

```bash
cd infra/bootstrap
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

This creates:

- S3 bucket with versioning, encryption, and public access blocking
- DynamoDB table with pay-per-request billing and point-in-time recovery
- IAM account alias

### Step 2: Configure Main Terraform

The main Terraform configuration in `../main.tf` is already configured to use the bootstrap resources as its backend.

### Step 3: Initialize Main Configuration

```bash
cd ..
terraform init -migrate-state
```

This migrates any existing local state to the S3 backend.

## Configuration Files

- `main.tf` - Bootstrap resources definition
- `variables.tf` - Input variables for the bootstrap
- `terraform.tfvars` - Variable values (customize as needed)

## Security Features

- **Encryption**: S3 bucket uses AES256 server-side encryption
- **Versioning**: S3 bucket has versioning enabled for state history
- **Access Control**: Public access is completely blocked
- **Locking**: DynamoDB provides state locking to prevent concurrent operations

## Usage

### For New Team Members

1. Ensure you have AWS credentials configured
2. Run the bootstrap if resources don't exist:
   ```bash
   cd infra/bootstrap
   terraform apply -var-file=terraform.tfvars
   ```
3. Initialize the main configuration:
   ```bash
   cd ..
   terraform init
   ```

### For Existing Team Members

The backend is already configured, so just run:
```bash
terraform init
terraform plan
```

## State Management

- State files are stored in: `s3://magebase-tf-state-us-east-1/magebase/terraform.tfstate`
- State locking is handled automatically by DynamoDB
- State is encrypted at rest in S3

## Troubleshooting

### Backend Initialization Issues

If you get backend initialization errors:

1. Ensure the bootstrap resources exist:
   ```bash
   cd infra/bootstrap
   terraform plan
   ```

2. Check AWS credentials and permissions

3. Verify the S3 bucket and DynamoDB table exist in the correct region

### State Locking Issues

If state is locked:

1. Check for running Terraform processes
2. Use `terraform force-unlock LOCK_ID` if necessary
3. The lock will automatically expire after 20 minutes

## Cost Considerations

- **S3**: Minimal cost for storage and requests
- **DynamoDB**: Pay-per-request pricing (very low cost for typical usage)
- **IAM**: No additional cost for account alias

## Best Practices

1. **Never modify state files directly** - Always use Terraform commands
2. **Commit bootstrap configuration** - The bootstrap state should be committed to version control
3. **Use consistent naming** - Follow the established naming conventions
4. **Regular backups** - S3 versioning provides automatic backups
5. **Monitor costs** - Set up billing alerts for unexpected usage

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `region` | AWS region for resources | `us-east-1` |
| `account_alias` | IAM account alias | `magebase` |
| `environment` | Environment tag | `dev` |
| `dynamodb_table_name` | DynamoDB table name | `magebase-terraform-locks` |

## Related Documentation

- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends)
- [AWS S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)
