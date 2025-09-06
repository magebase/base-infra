# Terragrunt configuration for qa environment base infrastructure
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "qa"
  # QA environment uses fsn1 and nbg1 regions
  regions = ["fsn1", "nbg1"]
  domain_name = "qa.magebase.dev"
}

# This is a parent config - actual deployments are in region subdirs
