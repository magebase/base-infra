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

# Route 53 TXT record for domain verification
resource "aws_route53_record" "ses_verification" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "_amazonses.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}

# Route 53 TXT records for DKIM
resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Route 53 TXT record for SPF
resource "aws_route53_record" "ses_spf" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "mail.${var.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com ~all"]
}

# Route 53 MX record for mail from domain
resource "aws_route53_record" "ses_mx" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "mail.${var.domain_name}"
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.ap-southeast-1.amazonses.com"]
}

# Data source for Route 53 zone (assuming it exists)
data "aws_route53_zone" "main" {
  name = var.domain_name
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
