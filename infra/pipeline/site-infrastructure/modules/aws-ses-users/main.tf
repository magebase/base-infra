# AWS SES Users Module
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "environment" {
  description = "Environment name (dev, qa, uat, prod)"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID where the SES users will be created"
  type        = string
}

# SES IAM Users for each environment
resource "aws_iam_user" "ses_user" {
  name = "ses-${var.environment}-user"

  tags = {
    Environment = var.environment
    Purpose     = "SES Email Service"
    ManagedBy   = "terraform"
  }

  lifecycle {
    ignore_changes = [
      name, # Allow existing users to be preserved
    ]
  }
}

# IAM Access Key for SES User
resource "aws_iam_access_key" "ses_user" {
  user = aws_iam_user.ses_user.name
}

# IAM Policy for SES User
resource "aws_iam_user_policy" "ses_policy" {
  name = "SESSendEmailPolicy-${var.environment}"
  user = aws_iam_user.ses_user.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "ses:SendTemplatedEmail",
          "ses:GetSendQuota",
          "ses:GetSendStatistics",
          "ses:ListIdentities",
          "ses:VerifyEmailIdentity",
          "ses:VerifyDomainIdentity",
          "ses:GetIdentityVerificationAttributes",
          "ses:SetIdentityNotificationTopic",
          "ses:GetIdentityNotificationAttributes"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "arn:aws:ses:*:${var.account_id}:identity/*"
        Condition = {
          StringEquals = {
            "ses:FromAddress" : "*@magebase.dev"
          }
        }
      }
    ]
  })
}

# Outputs
output "ses_user_name" {
  description = "Name of the SES IAM user"
  value       = aws_iam_user.ses_user.name
}

output "ses_access_key_id" {
  description = "Access Key ID for the SES user"
  value       = aws_iam_access_key.ses_user.id
  sensitive   = true
}

output "ses_secret_access_key" {
  description = "Secret Access Key for the SES user"
  value       = aws_iam_access_key.ses_user.secret
  sensitive   = true
}

output "ses_user_arn" {
  description = "ARN of the SES IAM user"
  value       = aws_iam_user.ses_user.arn
}
