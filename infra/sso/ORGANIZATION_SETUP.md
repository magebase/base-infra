# AWS Organizations Setup Guide

## Current Situation

You have an existing AWS account that you want to use as the **Management Account** for AWS Organizations.

## Step 1: Create AWS Organization

Since you already have an AWS account, you can convert it to be the management account of an AWS Organization.

### Option A: AWS Console (Recommended)

1. **Sign in to AWS Console** with your root account
2. **Go to AWS Organizations**:
   - Search for "Organizations" in the AWS Console
   - Click "Create organization"

3. **Choose Organization Features**:
   - Select "All features" (recommended for full functionality)
   - Click "Create organization"

4. **Verify Management Account**:
   - Your current account will become the management account
   - Note the **Management Account ID** (12-digit number) - you'll need this for GitHub secrets

### Option B: AWS CLI

```bash
# Create organization with all features
aws organizations create-organization --feature-set ALL

# Verify the organization was created
aws organizations describe-organization
```

## Step 2: Create Member Accounts

Once you have the organization, create development and production accounts:

### Create Development Account

```bash
aws organizations create-account \
  --email dev@magebase.dev \
  --account-name "Magebase Development" \
  --role-name OrganizationAccountAccessRole
```

### Create Production Account

```bash
aws organizations create-account \
  --email prod@magebase.dev \
  --account-name "Magebase Production" \
  --role-name OrganizationAccountAccessRole
```

## Step 3: Get Account IDs

After creating the accounts, get their IDs:

```bash
# List all accounts in your organization
aws organizations list-accounts

# Note the account IDs for:
# - Management account (your current account)
# - Development account
# - Production account
```

## Step 4: Set Up GitHub Secrets

In your GitHub repository, add these secrets:

```text
## Step 4: Set Up GitHub Variables and Secrets

In your GitHub repository, configure the following:

### Variables (Settings → Secrets and variables → Variables)

```text
MANAGEMENT_ACCOUNT_ID = [Your management account ID - 12 digits]
```

### Secrets (Settings → Secrets and variables → Actions)

```text
DEVELOPMENT_ACCOUNT_ID = [Development account ID - 12 digits]
PRODUCTION_ACCOUNT_ID = [Production account ID - 12 digits]
```

**Security Note**: We use variables for the management account ID since account IDs are publicly visible information and don't need to be hidden. Development and production account IDs are kept as secrets for additional security.
```

## Step 5: Enable AWS SSO

1. **Go to AWS SSO Service**:
   - Search for "SSO" in AWS Console
   - Click "Enable AWS SSO"

2. **Configure SSO Settings**:
   - Choose your SSO region (recommend `ap-southeast-1`)
   - Set up your identity source (you can use AWS SSO users initially)

## Quick Setup Script

Run this script to automate the entire setup:

```bash
#!/bin/bash

echo "🚀 Setting up AWS Organization and Accounts..."

# Create organization
echo "📋 Creating AWS Organization..."
aws organizations create-organization --feature-set ALL

# Wait a moment for organization to be ready
sleep 10

# Create development account
echo "🏗️ Creating development account..."
aws organizations create-account \
  --email dev@magebase.dev \
  --account-name "Magebase Development" \
  --role-name OrganizationAccountAccessRole

# Create production account
echo "🏭 Creating production account..."
aws organizations create-account \
  --email prod@magebase.dev \
  --account-name "Magebase Production" \
  --role-name OrganizationAccountAccessRole

# Wait for accounts to be created
echo "⏳ Waiting for accounts to be fully created..."
sleep 30

# Get account information
echo "📊 Getting account information..."
aws organizations list-accounts --query 'Accounts[].[Name,Id,Email]' --output table

echo "✅ AWS Organization setup complete!"
echo ""
echo "📝 Next steps:"
echo "1. Note the account IDs from the table above"
echo "2. Add them as secrets in your GitHub repository"
echo "3. Follow the SSO setup guide in infra/sso/AWS_SETUP_GUIDE.md"
```

## Verification

After setup, verify everything is working:

```bash
# Check organization status
aws organizations describe-organization

# List all accounts
aws organizations list-accounts

# Check if SSO is enabled
aws sso-admin list-instances
```

## Important Notes

- **Management Account**: Your current account becomes the management account
- **Billing**: All member accounts' charges appear on the management account
- **Root Access**: Keep root access secure - use IAM users/roles for daily operations
- **Regions**: AWS Organizations and SSO work across all regions, but choose one home region

## Troubleshooting

### "OrganizationAlreadyExistsException"

If you get this error, you already have an organization. Check:

```bash
aws organizations describe-organization
```

### Account Creation Delays

Account creation can take 5-10 minutes. Check status:

```bash
aws organizations list-accounts --query 'Accounts[?State!=`ACTIVE`]'
```

Once you have the account IDs, you can proceed with the SSO setup using the `AWS_SETUP_GUIDE.md` in the `infra/sso/` directory.
