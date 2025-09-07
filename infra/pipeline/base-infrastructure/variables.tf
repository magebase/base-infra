# Variables for base infrastructure (k3s cluster)
variable "environment" {
  description = "Environment name (dev, prod, qa, uat)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "prod", "qa", "uat"], var.environment)
    error_message = "Environment must be one of: dev, prod, qa, uat"
  }
}

variable "management_account_id" {
  description = "AWS Account ID for management account (used for accessing SSM parameters)"
  type        = string
}

variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for cluster access"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "SSH private key for cluster access"
  type        = string
  sensitive   = true
}

variable "hetzner_region" {
  description = "Hetzner Cloud region/datacenter location"
  type        = string
  default     = "fsn1"
  validation {
    condition     = contains(["fsn1", "nbg1", "hel1", "ash", "sin"], var.hetzner_region)
    error_message = "Hetzner region must be one of: fsn1 (Falkenstein), nbg1 (Nuremberg), hel1 (Helsinki), ash (Ashburn), sin (Singapore)"
  }
}

variable "domain" {
  description = "Domain name for the cluster (used for ArgoCD ingress)"
  type        = string
  default     = ""
}

variable "argocd_admin_password" {
  description = "ArgoCD admin password (bcrypt hashed)"
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = var.argocd_admin_password != ""
    error_message = "ArgoCD admin password must be set and cannot be empty"
  }
}

variable "argocd_repo_token" {
  description = "GitHub Personal Access Token for ArgoCD repository access"
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = var.argocd_repo_token != ""
    error_message = "ArgoCD repository token must be set and cannot be empty"
  }
}

variable "encryption_key" {
  description = "32-byte base64-encoded encryption key for k3s secrets and etcd encryption"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:DNS:Edit and Zone:Zone:Read permissions for cert-manager DNS01 challenges"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_r2_access_key_id" {
  description = "Cloudflare R2 Access Key ID for PostgreSQL backups"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_r2_secret_access_key" {
  description = "Cloudflare R2 Secret Access Key for PostgreSQL backups"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID for R2 buckets"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for the domain"
  type        = string
  default     = ""
}

variable "client_name" {
  description = "Name of the client for external secrets roles (optional, defaults to genfix)"
  type        = string
  default     = ""
}

variable "control_plane_server_type" {
  description = "Hetzner Cloud server type for control plane nodes"
  type        = string
  default     = "cx22"
}

variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
  default     = 1
}

variable "agent_server_type" {
  description = "Hetzner Cloud server type for agent nodes"
  type        = string
  default     = "cax11"
}

variable "agent_count" {
  description = "Number of agent nodes"
  type        = number
  default     = 1
}
