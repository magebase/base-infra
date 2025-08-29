# Quick SES Setup (Without IAM Identity Center)

## Is Identity Center Overkill for SES?

**Yes, for simple SES usage, IAM Identity Center is overkill.** Here's why:

### When Identity Center Makes Sense

- Multiple AWS accounts (dev/prod/staging)
- Many users needing different permission levels
- Centralized user management across accounts
- Complex organizational structure

### When Direct IAM is Better

- Single account usage
- Simple service access (like SES)
- Quick prototyping/testing
- Minimal user management

## Quickest SES Setup (5 minutes)

### Step 1: Create IAM User for SES

```bash
# Create IAM user for SES operations
aws iam create-user --user-name ses-service-user

# Create access key
aws iam create-access-key --user-name ses-service-user
```

**Save the Access Key ID and Secret Access Key!**

### Step 2: Attach SES Policy

```bash
# Attach AmazonSESFullAccess policy
aws iam attach-user-policy \
  --user-name ses-service-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess
```

### Step 3: Configure AWS CLI (Optional)

```bash
# Configure AWS CLI with the new credentials
aws configure --profile ses-user
# Enter Access Key ID and Secret Access Key when prompted
```

### Step 4: Test SES Access

```bash
# Test SES access
aws ses get-send-quota --profile ses-user

# Or verify identity
aws ses verify-email-identity --email your-email@example.com --profile ses-user
```

## Alternative: Use Existing Root/Management Account

If you prefer not to create a new IAM user:

### Option A: Use Root Account (Not Recommended)

```bash
# Use root account credentials (less secure)
aws ses verify-email-identity --email your-email@example.com
```

### Option B: Create IAM Role (Better)

```bash
# Create role for SES access
cat > ses-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:root"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create the role
aws iam create-role \
  --role-name SESServiceRole \
  --assume-role-policy-document file://ses-role-trust-policy.json

# Attach SES policy
aws iam attach-role-policy \
  --role-name SESServiceRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

# Assume the role
aws sts assume-role \
  --role-arn arn:aws:iam::YOUR_ACCOUNT_ID:role/SESServiceRole \
  --role-session-name SES-Session
```

## GitHub Actions Setup (Quick)

For GitHub Actions, use the IAM user credentials:

### Repository Secrets

```text
AWS_ACCESS_KEY_ID_SES = [Access Key ID from step 1]
AWS_SECRET_ACCESS_KEY_SES = [Secret Access Key from step 1]
AWS_REGION = ap-southeast-1
```

### Workflow Example

```yaml
- name: Configure AWS for SES
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID_SES }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY_SES }}
    aws-region: ap-southeast-1

- name: Send Email via SES
  run: |
    aws ses send-email \
      --from your-verified-email@example.com \
      --to recipient@example.com \
      --subject "Test Email" \
      --text "Hello from SES!"
```

## When to Use Identity Center

**Use Identity Center when you have:**

- Multiple AWS accounts
- Need to manage many users
- Require centralized access control
- Need to integrate with external identity providers
- Plan to scale beyond basic SES usage

**For now, stick with direct IAM access for SES - it's simpler and faster to set up!**

## Cleanup (When Done)

```bash
# Delete IAM user when no longer needed
aws iam detach-user-policy \
  --user-name ses-service-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonSESFullAccess

aws iam delete-access-key \
  --user-name ses-service-user \
  --access-key-id YOUR_ACCESS_KEY_ID

aws iam delete-user --user-name ses-service-user
```
