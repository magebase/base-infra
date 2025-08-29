# AWS SSO Setup Guide

## Prerequisites

Before deploying the SSO configuration, you need to set up the following in your AWS Management Account:

### 1. Create GitHub OIDC Provider

```bash
# Create OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. Create IAM Role for GitHub Actions

Create a file named `github-actions-role.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:magebase/site:*"
        }
      }
    }
  ]
}
```

Create the role:

```bash
# Replace <MANAGEMENT_ACCOUNT_ID> with your actual account ID
aws iam create-role \
  --role-name GitHubActionsSSORole \
  --assume-role-policy-document file://github-actions-role.json

# Attach necessary permissions
aws iam attach-role-policy \
  --role-name GitHubActionsSSORole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### 3. Set Repository Variables

In your GitHub repository, go to Settings → Secrets and variables → Variables and add:

- `MANAGEMENT_ACCOUNT_ID`: Your AWS management account ID (12-digit number)
- `DEVELOPMENT_ACCOUNT_ID`: Your development account ID (if different) - **Secret**
- `PRODUCTION_ACCOUNT_ID`: Your production account ID (if different) - **Secret**

**Note**: We use variables for `MANAGEMENT_ACCOUNT_ID` since account IDs are not sensitive information and are publicly visible. Development and production account IDs are kept as secrets for additional security.

### 4. Verify Setup

Test the OIDC connection:

```bash
# This should work if everything is configured correctly
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::<MANAGEMENT_ACCOUNT_ID>:role/GitHubActionsSSORole \
  --role-session-name GitHubActions \
  --web-identity-token <GITHUB_TOKEN>
```

## Troubleshooting

### "Assuming role with OIDC" hangs

This usually means:

1. The `MANAGEMENT_ACCOUNT_ID` secret is not set or incorrect
2. The IAM role doesn't exist or has incorrect trust policy
3. The OIDC provider is not configured correctly

### "Access denied" errors

Check that:

1. The IAM role has the necessary permissions
2. The trust policy allows the correct repository
3. The OIDC provider thumbprint is current

### Role ARN format issues

Ensure the role ARN follows this format:

```text
arn:aws:iam::<ACCOUNT_ID>:role/GitHubActionsSSORole
```

Replace `<ACCOUNT_ID>` with your actual 12-digit AWS account ID.

## Quick Setup Script

Run this script in your management account to set everything up:

```bash
#!/bin/bash

# Replace with your actual account ID
ACCOUNT_ID="123456789012"
REPO="magebase/site"

# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${REPO}:*"
        }
      }
    }
  ]
}
EOF

# Create role
aws iam create-role \
  --role-name GitHubActionsSSORole \
  --assume-role-policy-document file://trust-policy.json

# Attach permissions
aws iam attach-role-policy \
  --role-name GitHubActionsSSORole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "Setup complete! Set MANAGEMENT_ACCOUNT_ID secret to: ${ACCOUNT_ID}"
```
