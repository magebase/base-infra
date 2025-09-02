# Cloudflare DNS Configuration Module
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# Variables
variable "domain_name" {
  description = "Domain name to configure in Cloudflare"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "cluster_ipv4" {
  description = "IPv4 address of the cluster ingress"
  type        = string
}

variable "cluster_ipv6" {
  description = "IPv6 address of the cluster ingress"
  type        = string
  default     = null
}

# SES DNS Records (optional)
variable "ses_verification_record" {
  description = "SES domain verification record"
  type = object({
    name    = string
    type    = string
    content = string
    ttl     = number
  })
  default = null
}

variable "ses_dkim_records" {
  description = "SES DKIM records"
  type = list(object({
    name    = string
    type    = string
    content = string
    ttl     = number
  }))
  default = []
}

variable "ses_dkim_tokens" {
  description = "Raw SES DKIM tokens from AWS SES"
  type        = list(string)
  default     = []
}

variable "aws_ses_account_id" {
  description = "AWS SES account ID to determine if SES is enabled"
  type        = string
  default     = ""
}

variable "ses_spf_record" {
  description = "SES SPF record"
  type = object({
    name    = string
    type    = string
    content = string
    ttl     = number
  })
  default = null
}

variable "ses_mx_record" {
  description = "SES MX record"
  type = object({
    name     = string
    type     = string
    content  = string
    priority = number
    ttl      = number
  })
  default = null
}

# Use provided zone_id
locals {
  zone_id = var.zone_id
}

# A record for the root domain
resource "cloudflare_dns_record" "root_a" {
  zone_id = local.zone_id
  name    = var.domain_name
  content = var.cluster_ipv4
  type    = "A"
  ttl     = var.cluster_ipv4 == "127.0.0.1" ? 600 : 1 # Use 600 for non-proxied, 1 for proxied
  proxied = var.cluster_ipv4 != "127.0.0.1"           # Don't proxy loopback addresses
}

# AAAA record for the root domain (if IPv6 is provided)
resource "cloudflare_dns_record" "root_aaaa" {
  count   = var.cluster_ipv6 != null ? 1 : 0
  zone_id = local.zone_id
  name    = var.domain_name
  content = var.cluster_ipv6
  type    = "AAAA"
  ttl     = 1 # Must be 1 when proxied is true
  proxied = true
}

# CNAME record for www subdomain
resource "cloudflare_dns_record" "www_cname" {
  zone_id = local.zone_id
  name    = "www"
  content = var.domain_name
  type    = "CNAME"
  ttl     = 1 # Must be 1 when proxied is true
  proxied = true
}

# CNAME record for CDN subdomain
resource "cloudflare_dns_record" "cdn_cname" {
  zone_id = local.zone_id
  name    = "cdn"
  content = var.domain_name
  type    = "CNAME"
  ttl     = 1 # Must be 1 when proxied is true
  proxied = true
}

# SES Domain Verification Record
resource "cloudflare_dns_record" "ses_verification" {
  count   = var.ses_verification_record != null ? 1 : 0
  zone_id = local.zone_id
  name    = trimsuffix(var.ses_verification_record.name, ".${var.domain_name}")
  content = var.ses_verification_record.content
  type    = var.ses_verification_record.type
  ttl     = var.ses_verification_record.ttl
  proxied = false
}

# SES DKIM Records - use static keys with raw DKIM tokens
resource "cloudflare_dns_record" "ses_dkim" {
  # Use static keys (0, 1, 2) since AWS SES always generates exactly 3 DKIM tokens
  for_each = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" ? toset(["0", "1", "2"]) : toset([])

  zone_id = local.zone_id
  name    = length(var.ses_dkim_tokens) > tonumber(each.key) ? "${var.ses_dkim_tokens[tonumber(each.key)]}._domainkey.${var.domain_name}" : "${tonumber(each.key) + 1}._domainkey.${var.domain_name}"
  content = length(var.ses_dkim_tokens) > tonumber(each.key) ? "${var.ses_dkim_tokens[tonumber(each.key)]}.dkim.amazonses.com" : "${tonumber(each.key) + 1}.dkim.amazonses.com"
  type    = "CNAME"
  ttl     = 600
  proxied = false
}

# SES SPF Record
resource "cloudflare_dns_record" "ses_spf" {
  count   = var.ses_spf_record != null ? 1 : 0
  zone_id = local.zone_id
  name    = trimsuffix(var.ses_spf_record.name, ".${var.domain_name}")
  content = var.ses_spf_record.content
  type    = var.ses_spf_record.type
  ttl     = var.ses_spf_record.ttl
  proxied = false
}

# SES MX Record
resource "cloudflare_dns_record" "ses_mx" {
  count    = var.ses_mx_record != null ? 1 : 0
  zone_id  = local.zone_id
  name     = trimsuffix(var.ses_mx_record.name, ".${var.domain_name}")
  content  = var.ses_mx_record.content
  type     = var.ses_mx_record.type
  ttl      = var.ses_mx_record.ttl
  priority = var.ses_mx_record.priority
  proxied  = false
}

# Advanced Cloudflare features commented out due to provider syntax issues
# These can be re-enabled once the Cloudflare provider syntax is resolved

# Outputs
output "zone_id" {
  value = local.zone_id
}

output "name_servers" {
  value = []
}
