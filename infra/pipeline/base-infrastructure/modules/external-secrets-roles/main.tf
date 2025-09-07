# AWS IAM users and policies for External Secrets Operator
# Each client gets a scoped user with access only to their parameters
# Since ESO runs in Hetzner k3s (outside AWS), we use access keys instead of role assumption

terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}

# IAM policy for genfix client - allows access to genfix parameters only
resource "aws_iam_policy" "external_secrets_genfix" {
  name        = "external-secrets-genfix-policy"
  description = "Policy for External Secrets Operator to access genfix parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/genfix/*"
      }
    ]
  })

  tags = var.tags
}

# IAM user for genfix client
resource "aws_iam_user" "external_secrets_genfix" {
  name = "external-secrets-genfix"
  tags = var.tags
}

# Access key for genfix user
resource "aws_iam_access_key" "external_secrets_genfix" {
  user = aws_iam_user.external_secrets_genfix.name
}

# Attach policy to genfix user
resource "aws_iam_user_policy_attachment" "external_secrets_genfix" {
  user       = aws_iam_user.external_secrets_genfix.name
  policy_arn = aws_iam_policy.external_secrets_genfix.arn
}

# IAM policy for site client - allows access to site parameters only
resource "aws_iam_policy" "external_secrets_site" {
  name        = "external-secrets-site-policy"
  description = "Policy for External Secrets Operator to access site parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/site/*"
      }
    ]
  })

  tags = var.tags
}

# IAM user for site client
resource "aws_iam_user" "external_secrets_site" {
  name = "external-secrets-site"
  tags = var.tags
}

# Access key for site user
resource "aws_iam_access_key" "external_secrets_site" {
  user = aws_iam_user.external_secrets_site.name
}

# Attach policy to site user
resource "aws_iam_user_policy_attachment" "external_secrets_site" {
  user       = aws_iam_user.external_secrets_site.name
  policy_arn = aws_iam_policy.external_secrets_site.arn
}
