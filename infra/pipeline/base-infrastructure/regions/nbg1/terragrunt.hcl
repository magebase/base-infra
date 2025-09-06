# Terragrunt configuration for Nuremberg (nbg1) region
include "root" {
  path = find_in_parent_folders()
}

locals {
  region = "nbg1"
  domain_name = "nbg1.magebase.dev"
  cluster_name = "magebase-nbg1"
}

inputs = {
  environment = "nbg1"
  domain_name = local.domain_name
  hetzner_region = local.region

  # Nuremberg cluster configuration
  cluster_name = local.cluster_name

  # Production-ready configuration for Nuremberg
  control_plane_server_type = "cax31"
  agent_server_type = "cax31"
  control_plane_count = 3  # HA setup
  agent_count = 5
}
