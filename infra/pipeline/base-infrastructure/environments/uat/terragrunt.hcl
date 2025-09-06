# Terragrunt configuration for uat environment base infrastructure
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "uat"
  # UAT environment uses fsn1, nbg1, and hel1 regions
  regions = ["fsn1", "nbg1", "hel1"]
  domain_name = "uat.magebase.dev"
}

# This is a parent config - actual deployments are in region subdirs
