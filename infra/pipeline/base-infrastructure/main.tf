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

# K3s cluster using kube-hetzner module
module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }

  source  = "kube-hetzner/kube-hetzner/hcloud"
  version = "2.15.3"

  hcloud_token     = var.hcloud_token
  ssh_public_key   = var.ssh_public_key
  ssh_private_key  = var.ssh_private_key
  network_region   = "ap-southeast"

  # Control plane configuration
  control_plane_nodepools = [
    {
      name        = "control-plane-sin",
      server_type = "cx22",
      location    = "sin",
      labels      = [],
      taints      = [],
      count       = 1
    },
    {
      name        = "control-plane-sin-ha",
      server_type = "cx22",
      location    = "sin",
      labels      = [],
      taints      = [],
      count       = 1
    },
    {
      name        = "control-plane-sin-backup",
      server_type = "cx22",
      location    = "sin",
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  # Agent nodepool configuration
  agent_nodepools = [
    {
      name        = "agent-small",
      server_type = "cx22",
      location    = "sin",
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  # Additional configuration
  cluster_name = local.cluster_name
  cni_plugin   = "cilium"
  enable_klipper_metal_lb = true
}

# Outputs
output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the k3s cluster"
}

output "kubeconfig" {
  value       = module.kube-hetzner.kubeconfig
  description = "Kubeconfig for accessing the cluster"
  sensitive   = true
}

output "ingress_public_ipv4" {
  value       = module.kube-hetzner.ingress_public_ipv4
  description = "Public IPv4 address for ingress"
}

output "ingress_public_ipv6" {
  value       = module.kube-hetzner.ingress_public_ipv6
  description = "Public IPv6 address for ingress"
}

output "network_id" {
  value       = module.kube-hetzner.network_id
  description = "Hetzner network ID"
}
