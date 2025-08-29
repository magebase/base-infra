# AWS SSO Management Setup

This directory contains Terraform configuration for AWS SSO/IAM Identity Center management with automated user group creation.

## Features

- **Automated Group Creation**: Creates user groups in AWS Identity Store
- **Permission Sets**: Pre-configured IAM permission sets for different roles
- **Account Assignments**: Automatic assignment of permissions to groups across accounts
- **Multi-Account Support**: Works with AWS Organizations member accounts

## User Groups Created

The following user groups are automatically created:

- **InfrastructureTeam**: Infrastructure management and deployment access
- **DevelopmentTeam**: Application development and deployment access
- **ProductionTeam**: Production environment management and operations
- **Auditors**: Read-only access for auditing and compliance

## Prerequisites

1. **AWS Management Account**: You need an AWS management account (the account that will host the SSO instance)
2. **AWS Organization**: The management account should be part of an AWS Organization
3. **Member Accounts**: Development and production accounts should be member accounts in the organization

## Required Secrets

Add the following secrets to your GitHub repository:

- `MANAGEMENT_ACCOUNT_ID`: The AWS account ID of your management account
- `DEVELOPMENT_ACCOUNT_ID`: The AWS account ID of your development account
- `PRODUCTION_ACCOUNT_ID`: The AWS account ID of your production account

## Setup Process

1. **Create AWS Organization** (if not already done):

   ```bash
   # In your management account
   aws organizations create-organization
   ```

2. **Create Member Accounts**:

   ```bash
   # Create development account
   aws organizations create-account \
     --email dev@magebase.dev \
     --account-name "Magebase Development"

   # Create production account
   aws organizations create-account \
     --email prod@magebase.dev \
     --account-name "Magebase Production"
   ```

3. **Configure Terraform Variables**:
   Update the `terraform.tfvars` file with your account IDs:

   ```hcl
   development_account_id = "123456789012"
   production_account_id  = "987654321098"
   ```

4. **Deploy SSO Configuration**:

   ```bash
   cd infra/sso
   terraform init
   terraform plan
   terraform apply
   ```

## Permission Sets

This configuration creates the following permission sets:

- **AdministratorAccess**: Full administrative access
- **InfrastructureManager**: Infrastructure deployment and management
- **ApplicationDeployment**: Application deployment and container management
- **SESManagement**: Amazon SES management and email sending
- **ReadOnlyAccess**: Read-only access for auditing

## Account Assignments

The configuration assigns permissions as follows:

### Management Account

- Administrator: `admin@magebase.dev` (user)
- Infrastructure: `InfrastructureTeam` (group)

### Development Account

- Infrastructure: `InfrastructureTeam` (group)
- Deployment: `DevelopmentTeam` (group)
- SES: `ses-service@magebase.dev` (user)

### Production Account

- Infrastructure: `InfrastructureTeam` (group)
- Deployment: `ProductionTeam` (group)
- Read-only: `Auditors` (group)

## Security Considerations

- The SSO instance is created in the management account
- Permission sets follow the principle of least privilege
- All resources are tagged for proper resource management
- GitHub Actions uses OIDC for secure authentication

## Troubleshooting

### User ID Placeholders

If you see errors related to `USER_ID_PLACEHOLDER_*`, you need to:

1. Create the users in AWS SSO console
2. Get their user IDs from the console
3. Update the Terraform configuration with actual user IDs
4. Re-run `terraform apply`

### Group Creation Issues

If groups fail to create, ensure:

- AWS SSO is properly enabled in your management account
- You have the necessary permissions to create Identity Store resources
- The identity store ID is correctly retrieved

## Next Steps

1. Configure your identity source (Active Directory, external IdP, or AWS SSO users)
2. Create users and assign them to groups
3. Test access to member accounts
4. Set up automated user provisioning with SCIM
5. Configure multi-factor authentication (MFA)
