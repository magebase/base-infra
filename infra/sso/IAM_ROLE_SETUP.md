# IAM Role Creation for GitHub Actions SSO

## Quick Role Creation

### Step 1: Get Your Account Information

First, get your AWS account ID and repository information:

```bash
# Your AWS Account ID (12 digits)
aws sts get-caller-identity --query Account --output text

# Your GitHub repository (format: owner/repo)
echo "magebase/site"
```

### Step 2: Create the IAM Role

Run this command to create the role with the correct trust policy:

```bash
#!/bin/bash

# Replace with your actual values
ACCOUNT_ID="YOUR_ACCOUNT_ID_HERE"  # 12-digit number
GITHUB_REPO="magebase/site"        # owner/repo format

# Create trust policy JSON
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
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_REPO}:*"
        }
      }
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name GitHubActionsSSORole \
  --assume-role-policy-document file://trust-policy.json \
  --description "Role for GitHub Actions to access AWS SSO resources"

# Attach AdministratorAccess policy (for SSO management)
aws iam attach-role-policy \
  --role-name GitHubActionsSSORole \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

# Verify the role was created
aws iam get-role --role-name GitHubActionsSSORole --query Role.Arn --output text

echo "✅ GitHubActionsSSORole created successfully!"
echo "Role ARN: arn:aws:iam::${ACCOUNT_ID}:role/GitHubActionsSSORole"
```

### Step 3: Verify the Role

Test that the role was created correctly:

```bash
# List the role
aws iam get-role --role-name GitHubActionsSSORole

# Check attached policies
aws iam list-attached-role-policies --role-name GitHubActionsSSORole
```

## Manual Creation (AWS Console)

If you prefer to use the AWS Console:

### 1. Go to IAM Console

- Open AWS IAM Console
- Click "Roles" in the left sidebar
- Click "Create role"

### 2. Configure Trust Policy

- Select "Web identity" as the trusted entity type
- Choose "token.actions.githubusercontent.com" as the identity provider
- Set the audience to "sts.amazonaws.com"
- Add this condition for your repository:

  ```text
  token.actions.githubusercontent.com:sub = repo:magebase/site:*
  ```

### 3. Attach Permissions

- Attach the "AdministratorAccess" policy
- Or create a custom policy with only the permissions needed for SSO management

### 4. Name and Create

- Role name: `GitHubActionsSSORole`
- Description: "Role for GitHub Actions to access AWS SSO resources"
- Click "Create role"

## Troubleshooting

### "OIDC provider not found"

If you get this error, you need to create the GitHub OIDC provider first:

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### "Access denied"

Make sure:

1. The account ID in the role ARN matches your AWS account
2. The repository name in the condition matches exactly: `magebase/site`
3. The role has the necessary permissions attached

### "Role already exists"

If the role already exists, update it:

```bash
# Update the trust policy
aws iam update-assume-role-policy \
  --role-name GitHubActionsSSORole \
  --policy-document file://trust-policy.json
```

## Verification

After creating the role, you can test it by running your GitHub Actions workflow. The workflow should now be able to assume the role successfully.

## Security Notes

- **AdministratorAccess**: This gives full access to your AWS account. Consider creating a custom policy with only the permissions needed for SSO management
- **Repository Restriction**: The role can only be assumed by workflows from the `magebase/site` repository
- **Branch Protection**: Consider restricting which branches can use this role

## Next Steps

1. ✅ Create the IAM role (following the steps above)
2. ✅ Set the `MANAGEMENT_ACCOUNT_ID` variable in your GitHub repository
3. ✅ Run your SSO management pipeline
4. ✅ The pipeline should now work without hanging

The role creation is the final missing piece for your SSO setup! 🚀
