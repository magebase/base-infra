# Terragrunt configuration for Ashburn (ash) region
include "root" {
  path = find_in_parent_folders()
}

locals {
  region = "ash"
  domain_name = "ash.magebase.dev"
  cluster_name = "magebase-ash"
}

inputs = {
  environment = "ash"
  domain_name = local.domain_name
  hetzner_region = local.region

  # Ashburn cluster configuration
  cluster_name = local.cluster_name

  # Standard configuration for Ashburn
  control_plane_server_type = "cax21"
  agent_server_type = "cax21"
  control_plane_count = 1
  agent_count = 3
}
