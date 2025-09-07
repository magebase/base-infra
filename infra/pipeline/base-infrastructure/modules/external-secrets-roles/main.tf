# AWS IAM roles and policies for External Secrets Operator
# Each client gets a scoped role with access only to their parameters

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

# IAM role for genfix client
resource "aws_iam_role" "external_secrets_genfix" {
  name = "external-secrets-genfix"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.external_secrets_trust_account_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to genfix role
resource "aws_iam_role_policy_attachment" "external_secrets_genfix" {
  role       = aws_iam_role.external_secrets_genfix.name
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

# IAM role for site client
resource "aws_iam_role" "external_secrets_site" {
  name = "external-secrets-site"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.external_secrets_trust_account_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to site role
resource "aws_iam_role_policy_attachment" "external_secrets_site" {
  role       = aws_iam_role.external_secrets_site.name
  policy_arn = aws_iam_policy.external_secrets_site.arn
}

# Template for additional client roles
# Copy and modify this block for new clients
resource "aws_iam_policy" "external_secrets_client_template" {
  count       = var.client_name != "" ? 1 : 0
  name        = "external-secrets-${var.client_name}-policy"
  description = "Policy for External Secrets Operator to access ${var.client_name} parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.client_name}/*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role" "external_secrets_client_template" {
  count = var.client_name != "" ? 1 : 0
  name  = "external-secrets-${var.client_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.external_secrets_trust_account_arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets_client_template" {
  count      = var.client_name != "" ? 1 : 0
  role       = aws_iam_role.external_secrets_client_template[0].name
  policy_arn = aws_iam_policy.external_secrets_client_template[0].arn
}

# IAM policy for IRSA role - allows access to all client parameters
resource "aws_iam_policy" "external_secrets_irsa" {
  name        = "external-secrets-irsa-policy"
  description = "Policy for External Secrets Operator IRSA to access all client parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "ssm:DescribeParameters"
        ]
        Resource = [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/genfix/*",
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/site/*"
        ]
      }
    ]
  })

  tags = var.tags
}

# IAM role for IRSA (IAM Roles for Service Accounts)
resource "aws_iam_role" "external_secrets_irsa" {
  name = "external-secrets-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.eks_oidc_provider_url}:sub" = "system:serviceaccount:external-secrets-system:external-secrets-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets_irsa" {
  role       = aws_iam_role.external_secrets_irsa.name
  policy_arn = aws_iam_policy.external_secrets_irsa.arn
}
