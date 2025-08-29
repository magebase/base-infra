# AWS Organizations & SSO Management

This directory contains Terraform configuration for **integrated AWS Organizations and SSO/IAM Identity Center management**. The setup ensures proper dependency ordering: Organizations accounts are created first, then SSO permissions are assigned.

## 🏗️ Architecture Overview

### What This Setup Does

1. **AWS Organizations** (`../organizations/`):
   - Creates Development and Production AWS accounts
   - Sets up Organizational Units (OUs)
   - Generates unique 12-digit account IDs

2. **AWS SSO/IAM Identity Center** (this directory):
   - Enables SSO in the management account
   - Creates permission sets and user groups
   - Assigns permissions to the created accounts

3. **GitHub Actions Pipeline**:
   - Orchestrates the entire deployment
   - Ensures Organizations runs before SSO
   - Validates account creation and assignments

### Key Benefits

- ✅ **No More Empty Account IDs**: Organizations creates accounts first
- ✅ **Automated Dependency Management**: Pipeline handles ordering
- ✅ **Integrated Setup**: Single pipeline for complete AWS account management
- ✅ **Validation**: Built-in checks prevent common deployment errors

## 📋 User Groups Created

The following user groups are automatically created in AWS Identity Store:

- **InfrastructureTeam**: Infrastructure management and deployment access
- **DevelopmentTeam**: Application development and deployment access
- **ProductionTeam**: Production environment management and operations
- **Auditors**: Read-only access for auditing and compliance

## 🚀 Quick Start

### Prerequisites

1. **AWS Organization Setup** (handled automatically by pipeline)
2. **GitHub OIDC Configuration** (one-time setup)
3. **Repository Variables & Secrets** (one-time setup)

### Automated Deployment

The GitHub Actions pipeline handles everything automatically:

```bash
# Pipeline triggers on changes to:
# - infra/organizations/** (account creation)
# - infra/sso/** (SSO configuration)
# - infra/main.tf (orchestration)
```

### Manual Trigger

```bash
# Via GitHub CLI
gh workflow run "AWS Organizations & SSO Management Pipeline"

# Via GitHub Web UI
# Actions → AWS Organizations & SSO Management Pipeline → Run workflow
```

**Secrets** (hidden from logs):

- `DEVELOPMENT_ACCOUNT_ID`: Your development account ID (if different)
- `PRODUCTION_ACCOUNT_ID`: Your production account ID (if different)

### 4. Troubleshooting Hanging Workflows

If your workflow hangs at "Assuming role with OIDC":

1. **Check Repository Secrets**: Ensure `MANAGEMENT_ACCOUNT_ID` is set correctly
2. **Verify IAM Role**: Confirm the `GitHubActionsSSORole` exists with correct trust policy
3. **OIDC Provider**: Ensure GitHub OIDC provider is configured in AWS
4. **Permissions**: Verify the role has necessary permissions for SSO operations

See [`AWS_SETUP_GUIDE.md`](AWS_SETUP_GUIDE.md) for detailed troubleshooting steps.

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
