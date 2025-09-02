terraform {
  required_version = ">= 1.8.0"

  # Backend configuration using management account with separate key for env-accounts
  backend "s3" {
    bucket  = "magebase-tf-state-management-ap-southeast-1"
    key     = "magebase/env-accounts/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# =============================================================================
# Environment Accounts Configuration
# =============================================================================
#
# This configuration sets up IAM users, roles, and SSO account assignments
# for development and production AWS accounts.
#
# Prerequisites:
# 1. AWS SSO must be enabled in the management account
# 2. org-sso configuration must be applied first to create:
#    - SSO permission sets
#    - User groups and users in Identity Store
#    - Account assignments for management account
# 3. Account IDs must be provided (either as variables or from org-sso outputs)
#
# The configuration will:
# - Create IAM users in each environment account
# - Set up GitHub Actions OIDC providers and roles
# - Create SSO account assignments if SSO is fully configured
# =============================================================================

# Management Account Provider
provider "aws" {
  region = var.region

  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Development Account Provider
provider "aws" {
  alias  = "development"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.development_account_id}:role/OrganizationAccountAccessRole"
  }

  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Production Account Provider
provider "aws" {
  alias  = "production"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${var.production_account_id}:role/OrganizationAccountAccessRole"
  }

  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Validate SSO configuration before proceeding
data "null_data_source" "sso_validation" {
  count = local.sso_enabled && !local.sso_fully_configured ? 1 : 0

  inputs = {
    error = "SSO is enabled but not fully configured. Missing components: ${join(", ", [
      local.sso_validation.has_instance_arn ? "" : "instance_arn",
      local.sso_validation.has_identity_store ? "" : "identity_store",
      local.sso_validation.has_permission_sets ? "" : "permission_sets",
      local.sso_validation.has_user_groups ? "" : "user_groups",
      local.sso_validation.has_users ? "" : "users"
    ])}"
  }
}

# Validate that account IDs are properly set
data "null_data_source" "account_id_validation" {
  count = local.development_account_id == "" || local.production_account_id == "" ? 1 : 0

  inputs = {
    error = "Account IDs must be provided either as variables or from org-sso outputs. Development: ${local.development_account_id}, Production: ${local.production_account_id}"
  }
}

# Data source to read outputs from org-sso configuration
data "terraform_remote_state" "org_sso" {
  backend = "s3"
  config = {
    bucket  = "magebase-tf-state-management-ap-southeast-1"
    key     = "magebase/org-sso/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

# Validate that org-sso state exists and is accessible
data "null_data_source" "org_sso_state_validation" {
  inputs = {
    sso_enabled = data.terraform_remote_state.org_sso.outputs.sso_enabled
  }
}

locals {
  # Find existing accounts by email
  existing_development_account = [for acc in data.aws_organizations_organization.accounts.accounts : acc if acc.email == var.development_email]
  existing_production_account  = [for acc in data.aws_organizations_organization.accounts.accounts : acc if acc.email == var.production_email]

  # Use provided account IDs or discover from existing accounts, or get from org-sso outputs
  development_account_id = var.development_account_id != "" ? var.development_account_id : (length(local.existing_development_account) > 0 ? local.existing_development_account[0].id : data.terraform_remote_state.org_sso.outputs.development_account_id)
  production_account_id  = var.production_account_id != "" ? var.production_account_id : (length(local.existing_production_account) > 0 ? local.existing_production_account[0].id : data.terraform_remote_state.org_sso.outputs.production_account_id)

  # Get SSO data from org-sso outputs
  sso_enabled       = data.terraform_remote_state.org_sso.outputs.sso_enabled
  sso_instance_arn  = data.terraform_remote_state.org_sso.outputs.sso_instance_arn
  identity_store_id = data.terraform_remote_state.org_sso.outputs.identity_store_id
  permission_sets   = data.terraform_remote_state.org_sso.outputs.permission_sets
  user_groups       = data.terraform_remote_state.org_sso.outputs.user_groups
  users             = data.terraform_remote_state.org_sso.outputs.users

  # Validate SSO configuration
  sso_validation = local.sso_enabled ? {
    has_instance_arn    = local.sso_instance_arn != null && local.sso_instance_arn != ""
    has_identity_store  = local.identity_store_id != null && local.identity_store_id != ""
    has_permission_sets = length(local.permission_sets) > 0
    has_user_groups     = length(local.user_groups) > 0
    has_users           = length(local.users) > 0
    } : {
    has_instance_arn    = false
    has_identity_store  = false
    has_permission_sets = false
    has_user_groups     = false
    has_users           = false
  }

  # SSO is fully configured only if all components are available
  sso_fully_configured = local.sso_enabled && alltrue([
    local.sso_validation.has_instance_arn,
    local.sso_validation.has_identity_store,
    local.sso_validation.has_permission_sets,
    local.sso_validation.has_user_groups,
    local.sso_validation.has_users
  ])

  # IAM Users Configuration
  iam_users = {
    admin = {
      name    = "admin"
      purpose = "Administrative access"
    }
    developer = {
      name    = "developer"
      purpose = "Application development"
    }
    auditor = {
      name    = "auditor"
      purpose = "Read-only access for auditing"
    }
  }

  # Account Assignments for environment accounts
  account_assignments = {
    # Development Account Assignments
    development_administrator = {
      account_id     = local.development_account_id
      permission_set = "administrator"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    development_infrastructure = {
      account_id     = local.development_account_id
      permission_set = "infrastructure"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    development_deployment = {
      account_id     = local.development_account_id
      permission_set = "deployment"
      principal_type = "GROUP"
      principal_name = "DevelopmentTeam"
    }
    development_ses = {
      account_id     = local.development_account_id
      permission_set = "ses"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    development_readonly = {
      account_id     = local.development_account_id
      permission_set = "readonly"
      principal_type = "GROUP"
      principal_name = "Auditors"
    }

    # Production Account Assignments
    production_administrator = {
      account_id     = local.production_account_id
      permission_set = "administrator"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    production_infrastructure = {
      account_id     = local.production_account_id
      permission_set = "infrastructure"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    production_deployment = {
      account_id     = local.production_account_id
      permission_set = "deployment"
      principal_type = "GROUP"
      principal_name = "ProductionTeam"
    }
    production_ses = {
      account_id     = local.production_account_id
      permission_set = "ses"
      principal_type = "GROUP"
      principal_name = "InfrastructureTeam"
    }
    production_readonly = {
      account_id     = local.production_account_id
      permission_set = "readonly"
      principal_type = "GROUP"
      principal_name = "Auditors"
    }

    # Individual User Assignments for Direct Access
    admin_development_admin = {
      account_id     = local.development_account_id
      permission_set = "administrator"
      principal_type = "USER"
      principal_name = "admin_user"
    }
    admin_production_admin = {
      account_id     = local.production_account_id
      permission_set = "administrator"
      principal_type = "USER"
      principal_name = "admin_user"
    }
    developer_development = {
      account_id     = local.development_account_id
      permission_set = "deployment"
      principal_type = "USER"
      principal_name = "developer_user"
    }
    auditor_readonly_dev = {
      account_id     = local.development_account_id
      permission_set = "readonly"
      principal_type = "USER"
      principal_name = "auditor_user"
    }
    auditor_readonly_prod = {
      account_id     = local.production_account_id
      permission_set = "readonly"
      principal_type = "USER"
      principal_name = "auditor_user"
    }
  }

  # Build account assignments list with proper principal IDs
  account_assignments_list = [
    for assignment_key, assignment_config in local.account_assignments : {
      key                = assignment_key
      account_id         = assignment_config.account_id
      ps_name            = assignment_config.permission_set
      principal_type     = assignment_config.principal_type
      principal_name     = assignment_config.principal_name
      principal_id       = assignment_config.principal_type == "GROUP" ? lookup(local.user_groups, assignment_config.principal_name, "") : lookup(local.users, assignment_config.principal_name, "")
      permission_set_arn = lookup(local.permission_sets, assignment_config.permission_set, "")
      is_user            = assignment_config.principal_type == "USER"
    }
  ]
}

# IAM Users in Development Account
resource "aws_iam_user" "development" {
  for_each = local.iam_users

  provider = aws.development
  name     = each.value.name

  tags = {
    Environment = "development"
    Purpose     = each.value.purpose
    ManagedBy   = "terraform"
  }
}

# IAM Access Keys for Development Users
resource "aws_iam_access_key" "development" {
  for_each = aws_iam_user.development

  provider = aws.development
  user     = each.value.name
}

# IAM Users in Production Account
resource "aws_iam_user" "production" {
  for_each = local.iam_users

  provider = aws.production
  name     = each.value.name

  tags = {
    Environment = "production"
    Purpose     = each.value.purpose
    ManagedBy   = "terraform"
  }
}

# IAM Access Keys for Production Users
resource "aws_iam_access_key" "production" {
  for_each = aws_iam_user.production

  provider = aws.production
  user     = each.value.name
}

# GitHub Actions OIDC Provider for Development Account
resource "aws_iam_openid_connect_provider" "github_development" {
  count = 1

  provider = aws.development
  url      = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1" # GitHub's OIDC thumbprint
  ]

  tags = {
    Name        = "GitHubActionsOIDC"
    Environment = "development"
    Purpose     = "GitHub Actions CI/CD OIDC Provider"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# GitHub Actions OIDC Provider for Production Account
resource "aws_iam_openid_connect_provider" "github_production" {
  count = 1

  provider = aws.production
  url      = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1" # GitHub's OIDC thumbprint
  ]

  tags = {
    Name        = "GitHubActionsOIDC"
    Environment = "production"
    Purpose     = "GitHub Actions CI/CD OIDC Provider"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# GitHub Actions SSO Role for Development Account
resource "aws_iam_role" "github_actions_sso_development" {
  count = 1

  provider = aws.development
  name     = "GitHubActionsSSORole"

  # Trust policy allowing GitHub Actions OIDC provider to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.development_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:magebase/site:*"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::308488080915:role/GitHubActionsSSORole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "development"
    Purpose     = "GitHub Actions CI/CD"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# GitHub Actions SSO Role for Production Account
resource "aws_iam_role" "github_actions_sso_production" {
  count = 1

  provider = aws.production
  name     = "GitHubActionsSSORole"

  # Trust policy allowing GitHub Actions OIDC provider to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.production_account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:magebase/site:*"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::308488080915:role/GitHubActionsSSORole"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "production"
    Purpose     = "GitHub Actions CI/CD"
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Policy for GitHub Actions SSO Role - Development
resource "aws_iam_role_policy" "github_actions_sso_policy_development" {
  count = 1

  provider = aws.development
  name     = "GitHubActionsSSOPolicy"
  role     = aws_iam_role.github_actions_sso_development[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Administrative access for infrastructure management
      {
        Effect = "Allow"
        Action = [
          "iam:*",
          "organizations:*",
          "sso:*",
          "sso-admin:*",
          "identitystore:*"
        ]
        Resource = "*"
      },
      # Cross-account role assumption
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole",
          "arn:aws:iam::*:role/InfrastructureDeploymentRole",
          "arn:aws:iam::*:role/SESManagerRole"
        ]
      },
      # S3 access for Terraform state
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::magebase-tf-state-*",
          "arn:aws:s3:::magebase-tf-state-*/*"
        ]
      },
      # DynamoDB access for state locking
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/magebase-terraform-locks*"
      },
      # CloudWatch for monitoring
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      # EC2 for infrastructure management
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      # Route53 for DNS management
      {
        Effect = "Allow"
        Action = [
          "route53:*"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Policy for GitHub Actions SSO Role - Production
resource "aws_iam_role_policy" "github_actions_sso_policy_production" {
  count = 1

  provider = aws.production
  name     = "GitHubActionsSSOPolicy"
  role     = aws_iam_role.github_actions_sso_production[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Administrative access for infrastructure management
      {
        Effect = "Allow"
        Action = [
          "iam:*",
          "organizations:*",
          "sso:*",
          "sso-admin:*",
          "identitystore:*"
        ]
        Resource = "*"
      },
      # Cross-account role assumption
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole"
        ]
        Resource = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole",
          "arn:aws:iam::*:role/InfrastructureDeploymentRole",
          "arn:aws:iam::*:role/SESManagerRole"
        ]
      },
      # S3 access for Terraform state
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::magebase-tf-state-*",
          "arn:aws:s3:::magebase-tf-state-*/*"
        ]
      },
      # DynamoDB access for state locking
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/magebase-terraform-locks*"
      },
      # CloudWatch for monitoring
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*"
        ]
        Resource = "*"
      },
      # EC2 for infrastructure management
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*"
        ]
        Resource = "*"
      },
      # Route53 for DNS management
      {
        Effect = "Allow"
        Action = [
          "route53:*"
        ]
        Resource = "*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach AdministratorAccess policy to GitHub Actions SSO Role - Development
resource "aws_iam_role_policy_attachment" "github_actions_sso_admin_development" {
  count = 1

  provider   = aws.development
  role       = aws_iam_role.github_actions_sso_development[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_role.github_actions_sso_development]
}

# Attach AdministratorAccess policy to GitHub Actions SSO Role - Production
resource "aws_iam_role_policy_attachment" "github_actions_sso_admin_production" {
  count = 1

  provider   = aws.production
  role       = aws_iam_role.github_actions_sso_production[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_role.github_actions_sso_production]
}

# Outputs for debugging and verification
output "sso_enabled" {
  description = "Whether SSO is enabled"
  value       = local.sso_enabled
}

output "sso_fully_configured" {
  description = "Whether SSO is fully configured with all required components"
  value       = local.sso_fully_configured
}

output "sso_validation_details" {
  description = "Details about SSO configuration validation"
  value       = local.sso_validation
}

output "account_ids" {
  description = "Account IDs being used"
  value = {
    development = local.development_account_id
    production  = local.production_account_id
  }
}

output "sso_account_assignments_created" {
  description = "Number of SSO account assignments created"
  value       = length(aws_ssoadmin_account_assignment.main)
}

# Create account assignments for environment accounts (only if SSO is fully configured)
resource "aws_ssoadmin_account_assignment" "main" {
  for_each = {
    for item in local.account_assignments_list :
    item.key => item
    if local.sso_fully_configured && item.principal_id != "" && item.permission_set_arn != ""
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn
  principal_type     = each.value.principal_type
  principal_id       = each.value.principal_id
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}
