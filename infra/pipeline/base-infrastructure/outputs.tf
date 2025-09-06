# Outputs for the base infrastructure module

output "cluster_name" {
  value       = local.cluster_name
  description = "Name of the k3s cluster"
}

output "kubeconfig" {
  value       = module.kube-hetzner.kubeconfig
  description = "Kubernetes cluster configuration file"
  sensitive   = true
}

output "lb_ipv4" {
  value       = module.kube-hetzner.ingress_public_ipv4
  description = "IPv4 address of the load balancer"
}

output "cluster_endpoint" {
  value       = "https://${module.kube-hetzner.ingress_public_ipv4}:6443"
  description = "Kubernetes API server endpoint"
}

output "cloudflare_r2_bucket" {
  value       = module.cloudflare_r2.r2_bucket
  description = "Cloudflare R2 bucket for PostgreSQL backups"
}

output "cloudflare_r2_endpoint" {
  value       = module.cloudflare_r2.r2_endpoint
  description = "Cloudflare R2 endpoint URL"
  sensitive   = true
}
