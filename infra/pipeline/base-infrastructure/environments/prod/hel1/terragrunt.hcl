# Terragrunt configuration for prod environment - hel1 region
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  environment = "prod"
  region = "hel1"
  domain_name = "magebase.dev"
  # Prod uses large instances for performance
  cluster_instance_type = "cax31"
}

# Include the main infrastructure module
terraform {
  source = "../../../..//modules/cluster"
}

inputs = {
  environment = local.environment
  region = local.region
  domain_name = local.domain_name
  cluster_instance_type = local.cluster_instance_type
}
