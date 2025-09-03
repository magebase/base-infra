# Bootstrap Environment Account
## Architecture
## Best Practices
## Bootstrap Process
## Configuration Files
## Cost Considerations
## Integration with Workflows
## Overview
## Related Documentation
## Security Features
## State Management
## Troubleshooting
## Usage
## Variables
### Automated (Recommended)
### Backend Initialization Issues
### For Existing Environment Accounts
### For New Environment Accounts
### Manual Bootstrap (if needed)
### Module Configuration
### State Locking Issues
- **Access Control**: Public access is completely blocked
- **DynamoDB Table**: `magebase-terraform-locks-{environment}` - Provides state locking for the specific environment
- **DynamoDB**: Pay-per-request pricing (very low cost for typical usage)
- **Encryption**: S3 bucket uses AES256 server-side encryption
- **Environment Isolation**: Each environment (dev/prod) has its own bootstrap resources
- **Environment Isolation**: Resources are environment-specific to prevent cross-environment access
- **IAM**: No additional cost
- **Locking**: DynamoDB provides state locking to prevent concurrent operations
- **S3 Bucket**: `magebase-tf-state-bootstrap-{environment}-ap-southeast-1` - Stores Terraform state files for the specific environment
- **S3**: Minimal cost for storage and requests
- **Versioning**: S3 bucket has versioning enabled for state history
- DynamoDB table with pay-per-request billing and point-in-time recovery
- Resources are tagged with the specific environment
- S3 bucket with versioning, encryption, and public access blocking
- State files are stored in: `s3://magebase-tf-state-bootstrap-{environment}-ap-southeast-1/magebase/{module}/{environment}/terraform.tfstate`
- State is encrypted at rest in S3
- State locking is handled automatically by DynamoDB
- [AWS S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)
- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends)
- `main.tf` - Bootstrap resources definition
- `terraform.tfvars` - Variable values (customize as needed)
- `variables.tf` - Input variables for the bootstrap
1. **Commit bootstrap configuration** - The bootstrap state should be committed to version control
1. **Environment Bootstrap**: Creates S3 and DynamoDB resources in the target environment account
1. **Environment Isolation** - Keep environment resources separate for security
1. **Infrastructure Deployment**: Uses the bootstrapped backend for environment-specific state management
1. **Monitor costs** - Set up billing alerts for unexpected usage
1. **Never modify state files directly** - Always use Terraform commands
1. **Regular backups** - S3 versioning provides automatic backups
1. **State Management**: Keeps local statefile that only manages bootstrap resources for that environment
1. **Use consistent naming** - Follow the established naming conventions
1. **base-infrastructure** and **site-infrastructure** use the environment-specific backends
1. **bootstrap-env-account** creates environment-specific state resources
1. **org-sso** creates accounts and GitHubActionsSSORole
1. Check AWS credentials and permissions (ensure GitHubActionsSSORole has proper permissions)
1. Check for running Terraform processes
1. Ensure GitHubActionsSSORole exists in the account (created by org-sso)
1. Ensure the bootstrap-env-account resources exist:
1. Ensure the environment account exists (created by org-sso)
1. Initialize infrastructure modules with the new backend
1. Run the bootstrap-env-account job in the workflow
1. The lock will automatically expire after 20 minutes
1. Use `terraform force-unlock LOCK_ID` if necessary
1. Verify the S3 bucket and DynamoDB table exist in the correct region and account
If state is locked:
If you get backend initialization errors:
If you need to run bootstrap manually for a specific environment:
The backend is already configured, so just run:
The bootstrap process is now automated as part of the GitHub Actions workflow:
The bootstrap uses the following trussworks module configuration:
The workflow ensures proper ordering and dependencies between these steps.
This bootstrap is integrated into the unified infrastructure pipeline:
This creates:
This directory contains the bootstrap configuration for setting up Terraform state management for individual environment accounts (development and production).
This setup creates environment-specific S3 buckets and DynamoDB tables for Terraform state management. Unlike the main bootstrap which runs in the management account, this bootstrap runs in each environment account to provide isolated state management.
```
```
```
```
```
```
```
```
````
````bash
```bash
```bash
```hcl
account_alias = var.account_alias
bucket_purpose       = "tf-state-bootstrap-${var.environment}"
cd infra/pipeline/bootstrap-env-account
cd infra/pipeline/bootstrap-env-account
dynamodb_point_in_time_recovery = true
dynamodb_table_name  = var.dynamodb_table_name
enable_s3_public_access_block   = true
manage_account_alias           = var.create_account_alias
module "bootstrap_env" {
region        = var.region
source  = "trussworks/bootstrap/aws"
terraform apply -var-file=terraform.tfvars -var="environment=dev"
terraform init
terraform init
terraform plan
terraform plan -var-file=terraform.tfvars -var="environment=dev"
terraform plan -var="environment=dev"
version = "7.0.0"
| --------------------- | ------------------------ | -------------------------- |
| Variable              | Description              | Default                    |
| `account_alias`       | IAM account alias        | `magebase`                 |
| `dynamodb_table_name` | DynamoDB table name      | `magebase-terraform-locks` |
| `environment`         | Environment tag          | `dev`                      |
| `region`              | AWS region for resources | `ap-southeast-1`           |
}
