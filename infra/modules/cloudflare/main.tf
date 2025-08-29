# Cloudflare DNS Configuration Module
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

# Page Rules for CDN optimization
resource "cloudflare_page_rule" "root_cache" {
  zone_id = data.cloudflare_zone.main.id
  target  = "${var.domain_name}/*"

  actions {
    cache_level = "aggressive"
    edge_cache_ttl = 3600  # 1 hour
    browser_cache_ttl = 1800  # 30 minutes
    cache_key_fields {
      cookie {
        check_presence = ["session", "user", "_magebase_session"]
      }
      header {
        check_presence = ["Authorization", "X-CSRF-Token"]
      }
      host {
        resolved = true
      }
      query_string {
        ignore = false
      }
      user {
        device_type = false
        geo = false
        lang = false
      }
    }
  }

  priority = 2
}

# Page Rule for API endpoints (no caching)
resource "cloudflare_page_rule" "api_no_cache" {
  zone_id = data.cloudflare_zone.main.id
  target  = "${var.domain_name}/api/*"

  actions {
    cache_level = "bypass"
    disable_security = false
  }

  priority = 1
}

# Page Rule for CDN subdomain (cdn.magebase.dev) - additional caching rules
resource "cloudflare_page_rule" "cdn_subdomain_cache" {
  zone_id = data.cloudflare_zone.main.id
  target  = "cdn.${var.domain_name}/*"

  actions {
    cache_level = "cache_everything"
    edge_cache_ttl = 86400  # 24 hours
    browser_cache_ttl = 7200  # 2 hours
    # Additional CDN optimizations
    minify {
      css = "on"
      html = "on"
      js = "on"
    }
    mirage = "on"  # Enable Mirage for better mobile performance
  }

  priority = 3
}

# Rate limiting for the main application using Ruleset (replaces deprecated rate_limit)
resource "cloudflare_ruleset" "rate_limiting" {
  zone_id = data.cloudflare_zone.main.id
  name    = "Rate Limiting Rules"
  description = "Rate limiting rules for the main application"
  kind    = "zone"
  phase   = "http_ratelimit"

  rules {
    action = "block"
    action_parameters {
      response {
        status_code = 429
        content_type = "text/plain"
        content = "Rate limit exceeded. Please try again later."
      }
    }

    expression = "(http.request.uri.path matches \"^/.*\")"
    description = "Rate limit all requests to 1000 per minute"

    ratelimit {
      characteristics = ["cf.colo.id", "ip.src"]
      period = 60
      requests_per_period = 1000
      mitigation_timeout = 60
    }

    enabled = true
  }
}

# WAF Rules using Ruleset (replaces deprecated firewall_rule)
resource "cloudflare_ruleset" "waf_custom_rules" {
  zone_id = data.cloudflare_zone.main.id
  name    = "WAF Custom Rules"
  description = "Custom WAF rules for security"
  kind    = "zone"
  phase   = "http_request_firewall_custom"

  rules {
    action = "block"
    action_parameters {
      response {
        status_code = 403
        content_type = "text/plain"
        content = "Access denied"
      }
    }

    expression = "(http.user_agent contains \"badbot\" or http.user_agent contains \"scanner\" or http.user_agent contains \"crawler\")"
    description = "Block common bad bots"
    enabled = true
  }
}

# Cache Ruleset for CDN subdomain optimization
resource "cloudflare_ruleset" "cdn_cache_optimization" {
  zone_id = data.cloudflare_zone.main.id
  name    = "CDN Cache Optimization"
  description = "Enhanced caching rules for CDN subdomain"
  kind    = "zone"
  phase   = "http_request_cache_settings"

  rules {
    action = "set_cache_settings"
    action_parameters {
      cache = true
      edge_ttl {
        mode = "override_origin"
        default = 86400  # 24 hours
      }
      browser_ttl {
        mode = "override_origin"
        default = 7200  # 2 hours
      }
      cache_key {
        ignore_query_strings_order = true
        cache_deception_armor = true
      }
    }

    expression = "(http.host contains \"cdn.${var.domain_name}\")"
    description = "Optimize caching for CDN subdomain"
    enabled = true
  }
}

# SSL/TLS Settings
resource "cloudflare_zone_settings_override" "main" {
  zone_id = data.cloudflare_zone.main.id

  settings {
    ssl = "strict"
    always_use_https = "on"
    min_tls_version = "1.2"
    opportunistic_encryption = "on"
    automatic_https_rewrites = "on"
    http2 = "on"
    http3 = "on"
    brotli = "on"
  }
}

# Outputs
output "zone_id" {
  value = data.cloudflare_zone.main.id
}

output "name_servers" {
  value = data.cloudflare_zone.main.name_servers
}
