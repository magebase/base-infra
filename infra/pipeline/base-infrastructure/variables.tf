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

variable "argocd_fqdn" {
  description = "Fully qualified domain name for ArgoCD (e.g. argocd.magebase.dev)"
  type        = string
  default     = ""

}

variable "argocd_admin_password" {
  description = "ArgoCD admin password (bcrypt hashed)"
  type        = string
  default     = ""
  sensitive   = true
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
