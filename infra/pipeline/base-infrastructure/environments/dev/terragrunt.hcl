# Terragrunt configuration for dev environment base infrastructure
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "dev"
  # Dev environment uses only fsn1 region for cost efficiency
  regions = ["fsn1"]
  domain_name = "dev.magebase.dev"
}

# This is a parent config - actual deployments are in region subdirs
