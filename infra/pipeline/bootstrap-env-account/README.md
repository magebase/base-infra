# Bootstrap Environment Account

This directory contains the bootstrap configuration for setting up Terraform state management for individual environment accounts (development and production).

## Overview

This setup creates environment-specific S3 buckets and DynamoDB tables for Terraform state management. Unlike the main bootstrap which runs in the management account, this bootstrap runs in each environment account to provide isolated state management.

## Architecture

- **S3 Bucket**: `magebase-tf-state-bootstrap-{environment}-ap-southeast-1` - Stores Terraform state files for the specific environment
- **DynamoDB Table**: `magebase-terraform-locks-{environment}` - Provides state locking for the specific environment
- **Environment Isolation**: Each environment (dev/prod) has its own bootstrap resources

## Bootstrap Process

### Automated (Recommended)

The bootstrap process is now automated as part of the GitHub Actions workflow:

1. **Environment Bootstrap**: Creates S3 and DynamoDB resources in the target environment account
2. **State Management**: Keeps local statefile that only manages bootstrap resources for that environment
3. **Infrastructure Deployment**: Uses the bootstrapped backend for environment-specific state management

### Manual Bootstrap (if needed)

If you need to run bootstrap manually for a specific environment:

```bash
cd infra/pipeline/bootstrap-env-account
terraform init
terraform plan -var-file=terraform.tfvars -var="environment=dev"
terraform apply -var-file=terraform.tfvars -var="environment=dev"
```

This creates:

- S3 bucket with versioning, encryption, and public access blocking
- DynamoDB table with pay-per-request billing and point-in-time recovery
- Resources are tagged with the specific environment

### Module Configuration

The bootstrap uses the following trussworks module configuration:

```hcl
module "bootstrap_env" {
  source  = "trussworks/bootstrap/aws"
  version = "7.0.0"

  region        = var.region
  account_alias = var.account_alias

  bucket_purpose       = "tf-state-bootstrap-${var.environment}"
  dynamodb_table_name  = var.dynamodb_table_name

  dynamodb_point_in_time_recovery = true
  enable_s3_public_access_block   = true
  manage_account_alias           = var.create_account_alias
}
```

## Configuration Files

- `main.tf` - Bootstrap resources definition
- `variables.tf` - Input variables for the bootstrap
- `terraform.tfvars` - Variable values (customize as needed)

## Security Features

- **Encryption**: S3 bucket uses AES256 server-side encryption
- **Versioning**: S3 bucket has versioning enabled for state history
- **Access Control**: Public access is completely blocked
- **Locking**: DynamoDB provides state locking to prevent concurrent operations
- **Environment Isolation**: Resources are environment-specific to prevent cross-environment access

## Usage

### For New Environment Accounts

1. Ensure the environment account exists (created by org-sso)
2. Ensure GitHubActionsSSORole exists in the account (created by org-sso)
3. Run the bootstrap-env-account job in the workflow
4. Initialize infrastructure modules with the new backend

### For Existing Environment Accounts

The backend is already configured, so just run:

```bash
terraform init
terraform plan
```

## State Management

- State files are stored in: `s3://magebase-tf-state-bootstrap-{environment}-ap-southeast-1/magebase/{module}/{environment}/terraform.tfstate`
- State locking is handled automatically by DynamoDB
- State is encrypted at rest in S3

## Troubleshooting

### Backend Initialization Issues

If you get backend initialization errors:

1. Ensure the bootstrap-env-account resources exist:

   ```bash
   cd infra/pipeline/bootstrap-env-account
   terraform plan -var="environment=dev"
   ```

2. Check AWS credentials and permissions (ensure GitHubActionsSSORole has proper permissions)

3. Verify the S3 bucket and DynamoDB table exist in the correct region and account

### State Locking Issues

If state is locked:

1. Check for running Terraform processes
2. Use `terraform force-unlock LOCK_ID` if necessary
3. The lock will automatically expire after 20 minutes

## Cost Considerations

- **S3**: Minimal cost for storage and requests
- **DynamoDB**: Pay-per-request pricing (very low cost for typical usage)
- **IAM**: No additional cost

## Best Practices

1. **Never modify state files directly** - Always use Terraform commands
2. **Commit bootstrap configuration** - The bootstrap state should be committed to version control
3. **Use consistent naming** - Follow the established naming conventions
4. **Regular backups** - S3 versioning provides automatic backups
5. **Monitor costs** - Set up billing alerts for unexpected usage
6. **Environment Isolation** - Keep environment resources separate for security

## Variables

| Variable              | Description              | Default                    |
| --------------------- | ------------------------ | -------------------------- |
| `region`              | AWS region for resources | `ap-southeast-1`           |
| `account_alias`       | IAM account alias        | `magebase`                 |
| `environment`         | Environment tag          | `dev`                      |
| `dynamodb_table_name` | DynamoDB table name      | `magebase-terraform-locks` |

## Related Documentation

- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends)
- [AWS S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)

## Integration with Workflows

This bootstrap is integrated into the unified infrastructure pipeline:

1. **org-sso** creates accounts and GitHubActionsSSORole
2. **bootstrap-env-account** creates environment-specific state resources
3. **base-infrastructure** and **site-infrastructure** use the environment-specific backends

The workflow ensures proper ordering and dependencies between these steps.
