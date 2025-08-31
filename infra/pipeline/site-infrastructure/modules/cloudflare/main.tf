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

# Data source to get the zone
data "cloudflare_zone" "main" {
  name = var.domain_name
}

# A record for the root domain
resource "cloudflare_record" "root_a" {
  zone_id = data.cloudflare_zone.main.id
  name    = var.domain_name
  content = var.cluster_ipv4
  type    = "A"
  ttl     = 300
  proxied = true
}

# AAAA record for the root domain (if IPv6 is provided)
resource "cloudflare_record" "root_aaaa" {
  count   = var.cluster_ipv6 != null ? 1 : 0
  zone_id = data.cloudflare_zone.main.id
  name    = var.domain_name
  content = var.cluster_ipv6
  type    = "AAAA"
  ttl     = 300
  proxied = true
}

# CNAME record for www subdomain
resource "cloudflare_record" "www_cname" {
  zone_id = data.cloudflare_zone.main.id
  name    = "www"
  content = var.domain_name
  type    = "CNAME"
  ttl     = 300
  proxied = true
}

# CNAME record for CDN subdomain
resource "cloudflare_record" "cdn_cname" {
  zone_id = data.cloudflare_zone.main.id
  name    = "cdn"
  content = var.domain_name
  type    = "CNAME"
  ttl     = 300
  proxied = true
}

# SES Domain Verification Record
resource "cloudflare_record" "ses_verification" {
  count   = var.ses_verification_record != null ? 1 : 0
  zone_id = data.cloudflare_zone.main.id
  name    = trimsuffix(var.ses_verification_record.name, ".${var.domain_name}")
  content = var.ses_verification_record.content
  type    = var.ses_verification_record.type
  ttl     = var.ses_verification_record.ttl
  proxied = false
}

# SES DKIM Records - handle conditionally to avoid count dependency issues
resource "cloudflare_record" "ses_dkim" {
  # Create records only if SES is enabled and records are provided
  for_each = var.aws_ses_account_id != "" && var.aws_ses_account_id != "dummy" && length(var.ses_dkim_records) > 0 ? {
    for idx, record in var.ses_dkim_records : idx => record
  } : {}

  zone_id = data.cloudflare_zone.main.id
  name    = trimsuffix(each.value.name, ".${var.domain_name}")
  content = each.value.content
  type    = each.value.type
  ttl     = each.value.ttl
  proxied = false
}

# SES SPF Record
resource "cloudflare_record" "ses_spf" {
  count   = var.ses_spf_record != null ? 1 : 0
  zone_id = data.cloudflare_zone.main.id
  name    = trimsuffix(var.ses_spf_record.name, ".${var.domain_name}")
  content = var.ses_spf_record.content
  type    = var.ses_spf_record.type
  ttl     = var.ses_spf_record.ttl
  proxied = false
}

# SES MX Record
resource "cloudflare_record" "ses_mx" {
  count    = var.ses_mx_record != null ? 1 : 0
  zone_id  = data.cloudflare_zone.main.id
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
  value = data.cloudflare_zone.main.id
}

output "name_servers" {
  value = data.cloudflare_zone.main.name_servers
}
