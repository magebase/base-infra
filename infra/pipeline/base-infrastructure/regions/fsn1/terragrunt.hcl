# Terragrunt configuration for Frankfurt (fsn1) region
include "root" {
  path = find_in_parent_folders()
}

locals {
  region = "fsn1"
  domain_name = "fsn1.magebase.dev"
  cluster_name = "magebase-fsn1"
}

inputs = {
  environment = "fsn1"
  domain_name = local.domain_name
  hetzner_region = local.region

  # Frankfurt cluster configuration
  cluster_name = local.cluster_name

  # Standard configuration for Frankfurt
  control_plane_server_type = "cax11"
  agent_server_type = "cax11"
  control_plane_count = 1
  agent_count = 2
}
