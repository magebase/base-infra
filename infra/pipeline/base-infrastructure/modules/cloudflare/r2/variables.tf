variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID for R2"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
}

variable "zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
}
