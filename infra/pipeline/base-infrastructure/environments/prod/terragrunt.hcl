# Terragrunt configuration for prod environment base infrastructure
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "prod"
  # Prod environment uses all 5 regions for global availability
  regions = ["fsn1", "nbg1", "hel1", "ash", "sin"]
  domain_name = "magebase.dev"
}

# This is a parent config - actual deployments are in region subdirs
