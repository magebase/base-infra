# Terragrunt configuration for qa environment - fsn1 region
include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  environment = "qa"
  region = "fsn1"
  domain_name = "qa.magebase.dev"
  # QA uses medium instances
  cluster_instance_type = "cax21"
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
