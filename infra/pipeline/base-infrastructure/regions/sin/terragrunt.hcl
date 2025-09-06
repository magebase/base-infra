# Terragrunt configuration for Singapore (sin) region
include "root" {
  path = find_in_parent_folders()
}

locals {
  region = "sin"
  domain_name = "sin.magebase.dev"
  cluster_name = "magebase-sin"
}

inputs = {
  environment = "sin"
  domain_name = local.domain_name
  hetzner_region = local.region

  # Singapore cluster configuration
  cluster_name = local.cluster_name

  # Standard configuration for Singapore
  control_plane_server_type = "cax21"
  agent_server_type = "cax21"
  control_plane_count = 1
  agent_count = 3
}
