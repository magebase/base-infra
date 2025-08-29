# Stripe Infrastructure for Invoicing and Billing
terraform {
  required_providers {
    stripe = {
      source  = "lukasaron/stripe"
      version = "~> 1.0"
    }
  }
}

# Stripe Customer Portal Configuration
resource "stripe_customer_portal" "main" {
  business_profile {
    headline = "Manage your Magebase subscription and billing"
  }

  features {
    customer_update {
      allowed_updates = ["email", "name", "phone", "address"]
      enabled         = true
    }

    invoice_history {
      enabled = true
    }

    payment_method_update {
      enabled = true
    }

    subscription_cancel {
      enabled = true
      cancellation_reason {
        enabled = true
        options = ["too_expensive", "missing_features", "switched_service", "unused", "other"]
      }
    }

    subscription_pause {
      enabled = true
    }

    subscription_update {
      enabled                 = true
      default_allowed_updates = ["price", "quantity", "promotion_code"]
      proration_behavior      = "create_prorations"
    }
  }

  default_return_url = "https://${var.domain_name}/billing"
}

# Stripe Products for Services
resource "stripe_product" "web_development" {
  name        = "Web Development Services"
  description = "Custom web application development and deployment services"
  type        = "service"
  active      = true

  metadata = {
    category = "development"
    type     = "service"
  }
}

resource "stripe_product" "maintenance" {
  name        = "Monthly Maintenance & Support"
  description = "Ongoing maintenance, updates, and technical support"
  type        = "service"
  active      = true

  metadata = {
    category = "maintenance"
    type     = "recurring"
  }
}

resource "stripe_product" "consultation" {
  name        = "Technical Consultation"
  description = "One-time technical consultation and planning services"
  type        = "service"
  active      = true

  metadata = {
    category = "consultation"
    type     = "one-time"
  }
}

# Stripe Prices
resource "stripe_price" "web_development_hourly" {
  currency       = "usd"
  product        = stripe_product.web_development.id
  unit_amount    = 15000 # $150.00 per hour
  active         = true
  billing_scheme = "per_unit"

  metadata = {
    billing_type = "hourly"
  }
}

resource "stripe_price" "web_development_fixed" {
  currency       = "usd"
  product        = stripe_product.web_development.id
  unit_amount    = 500000 # $5,000.00 fixed price
  active         = true
  billing_scheme = "per_unit"

  metadata = {
    billing_type = "fixed"
  }
}

resource "stripe_price" "maintenance_monthly" {
  currency       = "usd"
  product        = stripe_product.maintenance.id
  unit_amount    = 50000 # $500.00 per month
  active         = true
  billing_scheme = "per_unit"
  recurring {
    interval       = "month"
    interval_count = 1
  }

  metadata = {
    billing_type = "monthly"
  }
}

resource "stripe_price" "consultation_fixed" {
  currency       = "usd"
  product        = stripe_product.consultation.id
  unit_amount    = 250000 # $2,500.00 fixed price
  active         = true
  billing_scheme = "per_unit"

  metadata = {
    billing_type = "fixed"
  }
}

# Stripe Tax Rates
resource "stripe_tax_rate" "us_sales_tax" {
  display_name = "US Sales Tax"
  percentage   = 8.25 # Example rate, should be configured per state
  inclusive    = false
  active       = true

  metadata = {
    country = "US"
    type    = "sales_tax"
  }
}

resource "stripe_tax_rate" "international_vat" {
  display_name = "International VAT"
  percentage   = 20.0 # Standard EU VAT rate
  inclusive    = false
  active       = true

  metadata = {
    region = "EU"
    type   = "vat"
  }
}

# Stripe Webhook Endpoints
resource "stripe_webhook_endpoint" "invoice_events" {
  url = "https://${var.domain_name}/api/webhooks/stripe"
  enabled_events = [
    "invoice.created",
    "invoice.finalized",
    "invoice.payment_succeeded",
    "invoice.payment_failed",
    "invoice.updated",
    "customer.subscription.created",
    "customer.subscription.updated",
    "customer.subscription.deleted",
    "payment_intent.succeeded",
    "payment_intent.payment_failed"
  ]

  metadata = {
    service = "magebase"
    type    = "billing"
  }
}

# Stripe Coupon for Retainer Discounts
resource "stripe_coupon" "retainer_discount" {
  name            = "Retainer Client Discount"
  percent_off     = 10
  duration        = "forever"
  max_redemptions = 100
  redeem_by       = 1735689600 # January 1, 2025

  metadata = {
    type        = "retainer"
    description = "10% discount for retainer clients"
  }
}

# Outputs
output "customer_portal_url" {
  description = "Stripe Customer Portal URL"
  value       = stripe_customer_portal.main.url
}

output "webhook_endpoint_id" {
  description = "Stripe Webhook Endpoint ID"
  value       = stripe_webhook_endpoint.invoice_events.id
}

output "webhook_endpoint_secret" {
  description = "Stripe Webhook Endpoint Secret"
  value       = stripe_webhook_endpoint.invoice_events.secret
  sensitive   = true
}

output "web_development_product_id" {
  description = "Web Development Product ID"
  value       = stripe_product.web_development.id
}

output "maintenance_product_id" {
  description = "Maintenance Product ID"
  value       = stripe_product.maintenance.id
}

output "consultation_product_id" {
  description = "Consultation Product ID"
  value       = stripe_product.consultation.id
}

output "hourly_price_id" {
  description = "Hourly Development Price ID"
  value       = stripe_price.web_development_hourly.id
}

output "fixed_price_id" {
  description = "Fixed Development Price ID"
  value       = stripe_price.web_development_fixed.id
}

output "monthly_maintenance_price_id" {
  description = "Monthly Maintenance Price ID"
  value       = stripe_price.maintenance_monthly.id
}

output "consultation_price_id" {
  description = "Consultation Price ID"
  value       = stripe_price.consultation_fixed.id
}
