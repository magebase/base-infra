# Terraform configuration for Magebase base infrastructure (k3s cluster)
terraform {
  required_version = ">= 1.8.0"

  # Backend configuration using S3 bucket created by bootstrap
  backend "s3" {
    bucket         = "magebase-tf-state-bootstrap-ap-southeast-1"
    region         = "ap-southeast-1"
    dynamodb_table = "magebase-terraform-locks-bootstrap"
    encrypt        = true
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.51.0"
    }
  }
}

# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Local values
locals {
  cluster_name = "${var.environment}-magebase"
}

# Outputs
output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the k3s cluster"
}
