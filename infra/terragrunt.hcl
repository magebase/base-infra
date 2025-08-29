# Root Terragrunt configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "magebase-terraform-state-${get_env("ENVIRONMENT", "dev")}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "magebase-terraform-locks"
  }
}

# Generate provider configuration
generate "provider" {
  path = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider for management account (organizations)
provider "aws" {
  alias  = "management"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.management_account_id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for network account
provider "aws" {
  alias  = "network"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.network.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for dev account
provider "aws" {
  alias  = "dev"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.dev.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for qa account
provider "aws" {
  alias  = "qa"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.qa.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for uat account
provider "aws" {
  alias  = "uat"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.uat.id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for prod account
provider "aws" {
  alias  = "prod"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.prod.id}:role/OrganizationAccountAccessRole"
  }
}

# Default AWS provider
provider "aws" {
  region = var.aws_region
}
EOF
}

# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}
