# Organizations Module
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Organization
resource "aws_organizations_organization" "main" {
  feature_set = "ALL"
}

# AWS Organization Accounts
resource "aws_organizations_account" "network" {
  name      = "Magebase Network"
  email     = "network@magebase.dev"
  role_name = "OrganizationAccountAccessRole"

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_account" "dev" {
  name      = "Magebase Dev"
  email     = "dev@magebase.dev"
  role_name = "OrganizationAccountAccessRole"

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_account" "qa" {
  name      = "Magebase QA"
  email     = "qa@magebase.dev"
  role_name = "OrganizationAccountAccessRole"

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_account" "uat" {
  name      = "Magebase UAT"
  email     = "uat@magebase.dev"
  role_name = "OrganizationAccountAccessRole"

  depends_on = [aws_organizations_organization.main]
}

resource "aws_organizations_account" "prod" {
  name      = "Magebase Prod"
  email     = "prod@magebase.dev"
  role_name = "OrganizationAccountAccessRole"

  depends_on = [aws_organizations_organization.main]
}

# Outputs
output "network_account_id" {
  value = aws_organizations_account.network.id
}

output "dev_account_id" {
  value = aws_organizations_account.dev.id
}

output "qa_account_id" {
  value = aws_organizations_account.qa.id
}

output "uat_account_id" {
  value = aws_organizations_account.uat.id
}

output "prod_account_id" {
  value = aws_organizations_account.prod.id
}
