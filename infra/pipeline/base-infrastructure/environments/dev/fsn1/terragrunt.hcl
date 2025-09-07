# Terragrunt configuration for dev environment - fsn1 region
include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  environment = "dev"
  region = "fsn1"
  domain_name = "dev.magebase.dev"
  # Dev uses smaller instances for cost efficiency
  cluster_instance_type = "cax11"
}

# Include the main infrastructure module
terraform {
  source = "../../..//."
}

inputs = {
  environment = local.environment
  region = local.region
  domain_name = local.domain_name
  cluster_instance_type = local.cluster_instance_type
}
