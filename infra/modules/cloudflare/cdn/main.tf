# Cloudflare CDN Configuration Module
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Variables
variable "domain_name" {
  description = "Domain name to configure CDN for"
  type        = string
}

variable "active_storage_bucket" {
  description = "Active Storage bucket name"
  type        = string
}

variable "object_storage_endpoint" {
  description = "Object storage endpoint URL"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

# CDN for Active Storage (cdn.magebase.dev) - CNAME record managed in main Cloudflare module

# Page Rule for Active Storage CDN optimization (cdn.magebase.dev)
resource "cloudflare_page_rule" "active_storage_cdn" {
  zone_id = var.zone_id
  target  = "cdn.${var.domain_name}/*"

  actions {
    cache_level       = "cache_everything"
    edge_cache_ttl    = 86400 # 24 hours
    browser_cache_ttl = 7200  # 2 hours
    cache_key_fields {
      cookie {
        check_presence = ["session", "user"]
      }
      header {
        check_presence = ["Authorization"]
      }
      host {
        resolved = true
      }
      query_string {
        ignore = false
      }
      user {
        device_type = false
        geo         = false
        lang        = false
      }
    }
  }

  priority = 1
}

# Rate limiting for Active Storage using Ruleset (replaces deprecated rate_limit)
resource "cloudflare_ruleset" "active_storage_rate_limiting" {
  zone_id     = var.zone_id
  name        = "Active Storage Rate Limiting"
  description = "Rate limiting rules for Active Storage files"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules {
    action = "block"
    action_parameters {
      response {
        status_code  = 429
        content_type = "text/plain"
        content      = "Rate limit exceeded"
      }
    }

    expression  = "(http.request.uri.path matches \"^/cdn/.*\")"
    description = "Rate limit CDN requests to 1000 per minute"

    ratelimit {
      characteristics     = ["cf.colo.id", "ip.src"]
      period              = 60
      requests_per_period = 1000
      mitigation_timeout  = 60
    }

    enabled = true
  }
}

# Outputs
output "active_storage_cdn_url" {
  value       = "https://cdn.${var.domain_name}"
  description = "CDN URL for Active Storage files"
}
