# Terraform State Management - Bootstrap Setup
## Architecture
## Best Practices
## Bootstrap Process
## Configuration Files
## Cost Considerations
## Overview
## Related Documentation
## Security Features
## State Management
## Troubleshooting
## Usage
## Variables
### Automated (Recommended)
### Backend Initialization Issues
### For Existing Team Members
### For New Team Members
### Manual Bootstrap (if needed)
### Module Configuration
### State Locking Issues
### Step 2: Configure Main Terraform
### Step 3: Initialize Main Configuration
- **Access Control**: Public access is completely blocked
- **DynamoDB Table**: `magebase-terraform-locks-bootstrap` - Provides state locking to prevent concurrent modifications
- **DynamoDB**: Pay-per-request pricing (very low cost for typical usage)
- **Encryption**: S3 bucket uses AES256 server-side encryption
- **IAM Account Alias**: `magebase` - Friendly account identifier
- **IAM**: No additional cost for account alias
- **Locking**: DynamoDB provides state locking to prevent concurrent operations
- **S3 Bucket**: `magebase-tf-state-bootstrap-ap-southeast-1` - Stores Terraform state files
- **S3**: Minimal cost for storage and requests
- **Versioning**: S3 bucket has versioning enabled for state history
- DynamoDB table with pay-per-request billing and point-in-time recovery
- IAM account alias (optional)
- S3 bucket with versioning, encryption, and public access blocking
- State files are stored in: `s3://magebase-tf-state-us-east-1/magebase/terraform.tfstate`
- State is encrypted at rest in S3
- State locking is handled automatically by DynamoDB
- [AWS S3 Backend](https://www.terraform.io/language/settings/backends/s3)
- [State Locking](https://www.terraform.io/language/state/locking)
- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends)
- `main.tf` - Bootstrap resources definition
- `terraform.tfvars` - Variable values (customize as needed)
- `variables.tf` - Input variables for the bootstrap
1. **Bootstrap**: Uses the trussworks module to create S3 and DynamoDB resources
1. **Commit bootstrap configuration** - The bootstrap state should be committed to version control
1. **Infrastructure Deployment**: Uses the bootstrapped backend for state management
1. **Monitor costs** - Set up billing alerts for unexpected usage
1. **Never modify state files directly** - Always use Terraform commands
1. **Regular backups** - S3 versioning provides automatic backups
1. **State Management**: Keeps local statefile that only manages bootstrap resources
1. **Use consistent naming** - Follow the established naming conventions
1. Check AWS credentials and permissions
1. Check for running Terraform processes
1. Ensure the bootstrap resources exist:
1. Ensure you have AWS credentials configured
1. Initialize the main configuration:
1. Run the bootstrap if resources don't exist:
1. The lock will automatically expire after 20 minutes
1. Use `terraform force-unlock LOCK_ID` if necessary
1. Verify the S3 bucket and DynamoDB table exist in the correct region
If state is locked:
If you get backend initialization errors:
If you need to run bootstrap manually:
The backend is already configured, so just run:
The bootstrap process is now automated as part of the GitHub Actions workflow:
The bootstrap uses the following trussworks module configuration:
The main Terraform configuration in `../main.tf` is already configured to use the bootstrap resources as its backend.
This creates:
This directory contains the bootstrap configuration for setting up Terraform state management with AWS S3 and DynamoDB using the [trussworks/bootstrap/aws](https://registry.terraform.io/modules/trussworks/bootstrap/aws) module.
This migrates any existing local state to the S3 backend.
This setup uses the proven trussworks bootstrap module to solve the chicken-and-egg problem of managing Terraform state. The module creates the backend resources (S3 bucket and DynamoDB table) in a separate Terraform configuration before using them in the main configuration.
```
```
```
```
```
```
```
```
```
```
`````
`````
````bash
```bash
```bash
```bash
```bash
```bash
```hcl
account_alias = var.account_alias
bucket_purpose       = "tf-state"
cd ..
cd ..
cd infra/bootstrap
cd infra/bootstrap
cd infra/bootstrap
dynamodb_point_in_time_recovery = true
dynamodb_table_name  = var.dynamodb_table_name
enable_s3_public_access_block   = true
manage_account_alias           = var.create_account_alias
module "bootstrap" {
region        = var.region
source  = "trussworks/bootstrap/aws"
terraform apply -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
terraform init
terraform init
terraform init
terraform init -migrate-state
terraform plan
terraform plan
terraform plan -var-file=terraform.tfvars
version = "7.0.0"
| --------------------- | ------------------------ | -------------------------- |
| Variable              | Description              | Default                    |
| `account_alias`       | IAM account alias        | `magebase`                 |
| `dynamodb_table_name` | DynamoDB table name      | `magebase-terraform-locks` |
| `environment`         | Environment tag          | `dev`                      |
| `region`              | AWS region for resources | `us-east-1`                |
}
