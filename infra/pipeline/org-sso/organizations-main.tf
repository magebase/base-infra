terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.8.0"
}

# Management Account Provider
provider "aws" {
  region = var.region # Organizations must be in us-east-1

  # Skip role assumption if credentials are already from an assumed role
  # This prevents circular role assumption when running in CI/CD or with SSO
  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Create Development Account
resource "aws_organizations_account" "development" {
  name      = "Magebase Development"
  email     = var.development_email
  role_name = "OrganizationAccountAccessRole"

  # Optional: Add to specific OU
  parent_id = local.development_ou_id

  tags = {
    Environment = "Development"
    Project     = "Magebase"
  }
}

# Create Production Account
resource "aws_organizations_account" "production" {
  name      = "Magebase Production"
  email     = var.production_email
  role_name = "OrganizationAccountAccessRole"

  # Optional: Add to specific OU
  parent_id = local.production_ou_id

  tags = {
    Environment = "Production"
    Project     = "Magebase"
  }
}

# Create Organizational Units (or reference existing ones)
data "aws_organizations_organizational_units" "existing" {
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

locals {
  existing_ou_names = toset([for ou in data.aws_organizations_organizational_units.existing.children : ou.name])
}

resource "aws_organizations_organizational_unit" "development" {
  count = contains(local.existing_ou_names, "Development") ? 0 : 1

  name      = "Development"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "production" {
  count = contains(local.existing_ou_names, "Production") ? 0 : 1

  name      = "Production"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

# Data sources for existing OUs
data "aws_organizations_organizational_unit" "development" {
  count = contains(local.existing_ou_names, "Development") ? 1 : 0

  name      = "Development"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

data "aws_organizations_organizational_unit" "production" {
  count = contains(local.existing_ou_names, "Production") ? 1 : 0

  name      = "Production"
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

locals {
  development_ou_id = contains(local.existing_ou_names, "Development") ? data.aws_organizations_organizational_unit.development[0].id : aws_organizations_organizational_unit.development[0].id
  production_ou_id   = contains(local.existing_ou_names, "Production") ? data.aws_organizations_organizational_unit.production[0].id : aws_organizations_organizational_unit.production[0].id
}

# Reference existing organization (don't create if it exists)
data "aws_organizations_organization" "main" {}

# Output the account IDs for use in SSO configuration
output "development_account_id" {
  description = "AWS Account ID for the development account"
  value       = aws_organizations_account.development.id
}

output "production_account_id" {
  description = "AWS Account ID for the production account"
  value       = aws_organizations_account.production.id
}
