# AWS SES Configuration Module
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "domain_name" {
  description = "Domain name for SES configuration"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID where the SES resources will be created"
  type        = string
}

variable "ses_manager_role_arn" {
  description = "ARN of the SES Manager IAM role (optional when using direct credentials)"
  type        = string
  default     = ""
}

# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

# SES Domain DKIM
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

# SES Domain Mail From
resource "aws_ses_domain_mail_from" "main" {
  domain           = aws_ses_domain_identity.main.domain
  mail_from_domain = "mail.${var.domain_name}"
}

# Outputs
output "domain_identity_arn" {
  value = aws_ses_domain_identity.main.arn
}

output "dkim_tokens" {
  value = aws_ses_domain_dkim.main.dkim_tokens
}

output "mail_from_domain" {
  value = aws_ses_domain_mail_from.main.mail_from_domain
}

output "ses_manager_role_arn" {
  value = var.ses_manager_role_arn != "" ? var.ses_manager_role_arn : null
}

# DNS Record outputs for Cloudflare
output "ses_verification_record" {
  description = "SES domain verification TXT record details"
  value = {
    name    = "_amazonses.${var.domain_name}"
    type    = "TXT"
    content = aws_ses_domain_identity.main.verification_token
    ttl     = 600
  }
}

output "ses_dkim_records" {
  description = "SES DKIM CNAME records details"
  value = [
    for i, token in aws_ses_domain_dkim.main.dkim_tokens : {
      name    = "${token}._domainkey.${var.domain_name}"
      type    = "CNAME"
      content = "${token}.dkim.amazonses.com"
      ttl     = 600
    }
  ]
}

output "ses_spf_record" {
  description = "SES SPF TXT record details"
  value = {
    name    = "mail.${var.domain_name}"
    type    = "TXT"
    content = "v=spf1 include:amazonses.com ~all"
    ttl     = 600
  }
}

output "ses_mx_record" {
  description = "SES MX record details"
  value = {
    name     = "mail.${var.domain_name}"
    type     = "MX"
    content  = "feedback-smtp.ap-southeast-1.amazonses.com"
    priority = 10
    ttl      = 600
  }
}
