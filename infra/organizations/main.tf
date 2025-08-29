terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

# Management Account Provider
provider "aws" {
  region = "us-east-1"  # Organizations must be in us-east-1
}

# Create Development Account
resource "aws_organizations_account" "development" {
  name      = "Magebase Development"
  email     = "magebase.dev+development@gmail.com"  # Replace with your email
  role_name = "OrganizationAccountAccessRole"

  # Optional: Add to specific OU
  parent_id = aws_organizations_organizational_unit.development.id

  tags = {
    Environment = "Development"
    Project     = "Magebase"
  }
}

# Create Production Account
resource "aws_organizations_account" "production" {
  name      = "Magebase Production"
  email     = "magebase.dev+production@gmail.com"  # Replace with your email
  role_name = "OrganizationAccountAccessRole"

  # Optional: Add to specific OU
  parent_id = aws_organizations_organizational_unit.production.id

  tags = {
    Environment = "Production"
    Project     = "Magebase"
  }
}

# Create Organizational Units
resource "aws_organizations_organizational_unit" "development" {
  name      = "Development"
  parent_id = aws_organizations_organization.main.roots[0].id
}

resource "aws_organizations_organizational_unit" "production" {
  name      = "Production"
  parent_id = aws_organizations_organization.main.roots[0].id
}

# Reference existing organization (don't create if it exists)
data "aws_organizations_organization" "main" {}

# Output the account IDs for use in SSO configuration
output "development_account_id" {
  value = aws_organizations_account.development.id
}

output "production_account_id" {
  value = aws_organizations_account.production.id
}
