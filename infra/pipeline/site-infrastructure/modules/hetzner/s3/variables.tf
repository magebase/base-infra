variable "cluster_name" {
  description = "Name of the cluster for bucket naming"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the object storage endpoint"
  type        = string
  default     = "magebase.dev"
}

variable "hetzner_object_storage_access_key" {
  description = "Hetzner Object Storage access key ID"
  type        = string
  sensitive   = true
}

variable "hetzner_object_storage_secret_key" {
  description = "Hetzner Object Storage secret access key"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Hetzner location for object storage (e.g., fsn1, sin)"
  type        = string
  default     = "fsn1"
}
