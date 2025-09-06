# Terragrunt configuration for Helsinki (hel1) region
include "root" {
  path = find_in_parent_folders()
}

locals {
  region = "hel1"
  domain_name = "hel1.magebase.dev"
  cluster_name = "magebase-hel1"
}

inputs = {
  environment = "hel1"
  domain_name = local.domain_name
  hetzner_region = local.region

  # Helsinki cluster configuration
  cluster_name = local.cluster_name

  # Standard configuration for Helsinki
  control_plane_server_type = "cax21"
  agent_server_type = "cax21"
  control_plane_count = 1
  agent_count = 3
}
