terraform {
  required_version = ">= 1.8.0"

  # Backend configuration using management account
  backend "s3" {
    bucket  = "magebase-tf-state-management-ap-southeast-1"
    key     = "magebase/org-sso/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }

  required_providers {
    aws = {
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

# Management Account Provider
provider "aws" {
  region = var.region # Organizations must be in us-east-1

  # Skip role assumption if credentials are already from an assumed role
  # This prevents circular role assumption when running in CI/CD or with SSO
  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Development Account Provider
provider "aws" {
  alias  = "development"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${local.development_account_id}:role/OrganizationAccountAccessRole"
  }

  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Production Account Provider
provider "aws" {
  alias  = "production"
  region = var.region

  assume_role {
    role_arn = "arn:aws:iam::${local.production_account_id}:role/OrganizationAccountAccessRole"
  }

  skip_metadata_api_check     = true
  skip_credentials_validation = true
}

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create Development Account (only if not importing and not already exists)
resource "aws_organizations_account" "development" {
  count = local.development_account_exists ? 0 : 1

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

# Create Production Account (only if not importing and not already exists)
resource "aws_organizations_account" "production" {
  count = local.production_account_exists ? 0 : 1

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

# Reference existing organization (don't create if it exists)
data "aws_organizations_organization" "main" {}

# Create Organizational Units (or reference existing ones)
data "aws_organizations_organizational_units" "existing" {
  parent_id = data.aws_organizations_organization.main.roots[0].id
}

locals {
  existing_ou_names = toset([for ou in data.aws_organizations_organizational_units.existing.children : ou.name])

  development_ou_id = contains(local.existing_ou_names, "Development") ? data.aws_organizations_organizational_unit.development[0].id : (length(aws_organizations_organizational_unit.development) > 0 ? aws_organizations_organizational_unit.development[0].id : "")
  production_ou_id  = contains(local.existing_ou_names, "Production") ? data.aws_organizations_organizational_unit.production[0].id : (length(aws_organizations_organizational_unit.production) > 0 ? aws_organizations_organizational_unit.production[0].id : "")

  # Check for existing accounts by email
  existing_development_account = [for acc in data.aws_organizations_organization.main.accounts : acc if acc.email == var.development_email]
  existing_production_account  = [for acc in data.aws_organizations_organization.main.accounts : acc if acc.email == var.production_email]

  development_account_exists = length(local.existing_development_account) > 0 || var.development_account_id != ""
  production_account_exists  = length(local.existing_production_account) > 0 || var.production_account_id != ""

  # Determine account IDs - prioritize explicit variables over discovery
  development_account_id = var.development_account_id != "" ? var.development_account_id : (length(local.existing_development_account) > 0 ? local.existing_development_account[0].id : (length(aws_organizations_account.development) > 0 ? aws_organizations_account.development[0].id : ""))
  production_account_id  = var.production_account_id != "" ? var.production_account_id : (length(local.existing_production_account) > 0 ? local.existing_production_account[0].id : (length(aws_organizations_account.production) > 0 ? aws_organizations_account.production[0].id : ""))
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

# Output the account IDs for use in SSO configuration
output "development_account_id" {
  description = "AWS Account ID for the development account"
  value       = local.development_account_id
}

output "production_account_id" {
  description = "AWS Account ID for the production account"
  value       = local.production_account_id
}

# Cloudflare Email Routing for AWS Account Emails
# resource "cloudflare_email_routing_rule" "aws_dev" {
#   zone_id = var.cloudflare_zone_id
#   name    = "AWS Development Account"
#   enabled = true

#   matchers = [
#     {
#       type  = "literal"
#       field = "to"
#       value = "aws-dev@magebase.dev"
#     }
#   ]

#   actions = [
#     {
#       type  = "forward"
#       value = [var.development_email]
#     }
#   ]
# }

# resource "cloudflare_email_routing_rule" "aws_prod" {
#   zone_id = var.cloudflare_zone_id
#   name    = "AWS Production Account"
#   enabled = true

#   matchers = [
#     {
#       type  = "literal"
#       field = "to"
#       value = "aws-prod@magebase.dev"
#     }
#   ]

#   actions = [
#     {
#       type  = "forward"
#       value = [var.production_email]
#     }
#   ]
# }

# AWS SSO/IAM Identity Center Configuration
# This should be deployed to the management account

locals {
  # SSO Configuration
  sso_instance_name = "magebase-sso"

  # Permission Sets
  permission_sets = {
    # Administrator Access
    administrator = {
      name        = "AdministratorAccess"
      description = "Full administrative access to AWS account"
      managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
    }

    # Infrastructure Management
    infrastructure = {
      name        = "InfrastructureManager"
      description = "Infrastructure deployment and management access"
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/IAMFullAccess",
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "organizations:ListAccounts",
              "organizations:DescribeAccount",
              "organizations:ListRoots",
              "organizations:ListOrganizationalUnitsForParent",
              "organizations:ListAccountsForParent"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "sts:AssumeRole"
            ]
            Resource = [
              "arn:aws:iam::*:role/OrganizationAccountAccessRole",
              "arn:aws:iam::*:role/InfrastructureDeploymentRole"
            ]
          }
        ]
      })
    }

    # Application Deployment
    deployment = {
      name        = "ApplicationDeployment"
      description = "Application deployment and container management access"
      managed_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:GetRepositoryPolicy",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:DescribeImages",
              "ecr:BatchGetImage",
              "ecr:GetLifecyclePolicy",
              "ecr:GetLifecyclePolicyPreview",
              "ecr:ListTagsForResource",
              "ecr:DescribeImageScanFindings"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "eks:DescribeCluster",
              "eks:ListClusters",
              "eks:DescribeNodegroup",
              "eks:ListNodegroups"
            ]
            Resource = "*"
          }
        ]
      })
    }

    # SES Management
    ses = {
      name        = "SESManagement"
      description = "Amazon SES management and email sending access"
      managed_policies = [
        "arn:aws:iam::aws:policy/AmazonSESFullAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "iam:CreateUser",
              "iam:DeleteUser",
              "iam:CreateAccessKey",
              "iam:DeleteAccessKey",
              "iam:ListAccessKeys",
              "iam:UpdateAccessKey"
            ]
            Resource = "arn:aws:iam::*:user/ses-*"
          }
        ]
      })
    }

    # Read Only
    readonly = {
      name        = "ReadOnlyAccess"
      description = "Read-only access for auditing and monitoring"
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
    }
  }

  # Account Assignments - Comprehensive assignments for all permission sets
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

  # User Groups Configuration
  user_groups = {
    InfrastructureTeam = {
      display_name = "Infrastructure Team"
      description  = "Team responsible for infrastructure management and deployment"
    }
    DevelopmentTeam = {
      display_name = "Development Team"
      description  = "Application development and deployment team"
    }
    ProductionTeam = {
      display_name = "Production Team"
      description  = "Production environment management and operations"
    }
    Auditors = {
      display_name = "Auditors"
      description  = "Read-only access for auditing and compliance"
    }
  }

  # Users Configuration - create users for each role type
  users = {
    # Infrastructure Team Users
    admin_user = {
      user_name    = "admin"
      display_name = "Administrator"
      given_name   = "Admin"
      family_name  = "User"
      email        = "admin@magebase.dev"
      groups       = ["InfrastructureTeam"]
    }
    infra_user = {
      user_name    = "infrastructure"
      display_name = "Infrastructure Manager"
      given_name   = "Infrastructure"
      family_name  = "Manager"
      email        = "infra@magebase.dev"
      groups       = ["InfrastructureTeam"]
    }

    # Development Team Users
    developer_user = {
      user_name    = "developer"
      display_name = "Developer"
      given_name   = "Dev"
      family_name  = "User"
      email        = "dev@magebase.dev"
      groups       = ["DevelopmentTeam"]
    }

    # Production Team Users
    prod_user = {
      user_name    = "production"
      display_name = "Production Manager"
      given_name   = "Prod"
      family_name  = "Manager"
      email        = "prod@magebase.dev"
      groups       = ["ProductionTeam"]
    }

    # Auditor Users
    auditor_user = {
      user_name    = "auditor"
      display_name = "Auditor"
      given_name   = "Audit"
      family_name  = "User"
      email        = "audit@magebase.dev"
      groups       = ["Auditors"]
    }
  }

  # Conditionally build managed policy attachments
  managed_policy_attachments = local.effective_sso_enabled ? flatten([
    for ps_name, ps_config in local.permission_sets : [
      for policy_arn in ps_config.managed_policies : {
        key        = "${ps_name}-${basename(policy_arn)}"
        ps_name    = ps_name
        policy_arn = policy_arn
      }
    ]
  ]) : []

  # Conditionally build account assignments (only groups for now, users need to be created first)
  account_assignments_list = local.effective_sso_enabled ? [
    for assignment_key, assignment_config in local.account_assignments : {
      key            = assignment_key
      account_id     = assignment_config.account_id
      ps_name        = assignment_config.permission_set
      principal_type = assignment_config.principal_type
      principal_name = assignment_config.principal_name
      is_user        = assignment_config.principal_type == "USER"
    }
  ] : []

  # Build user-group membership list
  user_group_memberships = local.effective_sso_enabled ? flatten([
    for user_key, user_config in local.users : [
      for group_name in user_config.groups : {
        key        = "${user_key}-${group_name}"
        user_name  = user_key
        group_name = group_name
      }
    ]
  ]) : []
}

# Get current account identity
data "aws_caller_identity" "current" {}

# Get AWS SSO instance (only if it exists)
data "aws_ssoadmin_instances" "main" {}

# Check if SSO is enabled - fallback to enabled if instance exists but data source fails
locals {
  sso_instance_count = length(data.aws_ssoadmin_instances.main.arns)
  sso_enabled        = local.sso_instance_count > 0
  sso_instance_arn   = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.arns)[0] : null
  identity_store_id  = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0] : null

  # Fallback values for when SSO is enabled but data source fails
  fallback_sso_instance_arn  = "arn:aws:sso:::instance/ssoins-821057ba6e937b40"
  fallback_identity_store_id = "d-9667b834c9"

  # Use fallback if data source fails but we know SSO exists
  effective_sso_instance_arn  = local.sso_enabled ? local.sso_instance_arn : local.fallback_sso_instance_arn
  effective_identity_store_id = local.sso_enabled ? local.identity_store_id : local.fallback_identity_store_id
  effective_sso_enabled       = true # Always enable SSO resources since instance exists
}

# Create Permission Sets (only if SSO is enabled)
resource "aws_ssoadmin_permission_set" "main" {
  for_each = {
    for k, v in local.permission_sets :
    k => v
    if local.effective_sso_enabled
  }

  name         = each.value.name
  description  = each.value.description
  instance_arn = local.effective_sso_instance_arn

  tags = {
    Name        = each.value.name
    Environment = "management"
    ManagedBy   = "terraform"
  }
}

# Attach managed policies to permission sets
resource "aws_ssoadmin_managed_policy_attachment" "managed_policies" {
  for_each = {
    for item in local.managed_policy_attachments :
    item.key => item
  }

  instance_arn       = local.effective_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.ps_name].arn
  managed_policy_arn = each.value.policy_arn
}

# Attach inline policies to permission sets
resource "aws_ssoadmin_permission_set_inline_policy" "inline_policies" {
  for_each = {
    for ps_name, ps_config in local.permission_sets :
    ps_name => ps_config
    if lookup(ps_config, "inline_policy", null) != null && local.effective_sso_enabled
  }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.effective_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.key].arn
}

# Create User Groups in AWS Identity Store (only if SSO is enabled)
resource "aws_identitystore_group" "main" {
  for_each = {
    for k, v in local.user_groups :
    k => v
    if local.effective_sso_enabled
  }

  display_name      = each.value.display_name
  description       = each.value.description
  identity_store_id = local.effective_identity_store_id
}

# Create Users in AWS Identity Store (only if SSO is enabled)
resource "aws_identitystore_user" "main" {
  for_each = {
    for k, v in local.users :
    k => v
    if local.effective_sso_enabled
  }

  identity_store_id = local.effective_identity_store_id
  user_name         = each.value.user_name
  display_name      = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    primary = true
    type    = "work"
    value   = each.value.email
  }

  lifecycle {
    ignore_changes = [
      # Allow users to change their own details
      display_name,
      name,
      emails,
    ]
  }
}

# Add Users to Groups (only if SSO is enabled)
resource "aws_identitystore_group_membership" "main" {
  for_each = {
    for item in local.user_group_memberships :
    item.key => item
  }

  identity_store_id = local.effective_identity_store_id
  group_id          = aws_identitystore_group.main[each.value.group_name].group_id
  member_id         = aws_identitystore_user.main[each.value.user_name].user_id

  depends_on = [
    aws_identitystore_group.main,
    aws_identitystore_user.main
  ]
}

# Create account assignments (only if SSO is enabled)
resource "aws_ssoadmin_account_assignment" "main" {
  for_each = {
    for item in local.account_assignments_list :
    item.key => item
  }

  instance_arn       = local.effective_sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.ps_name].arn
  principal_type     = each.value.principal_type
  principal_id = each.value.principal_type == "GROUP" ? (
    aws_identitystore_group.main[each.value.principal_name].group_id
    ) : (
    aws_identitystore_user.main[each.value.principal_name].user_id
  )
  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  # Add dependency on groups and users being created first
  depends_on = [
    aws_identitystore_group.main,
    aws_identitystore_user.main
  ]
}

# Data source to check if GitHub OIDC provider exists - Development
data "aws_iam_openid_connect_provider" "github_existing_development" {
  count    = 0 # Temporarily disabled to avoid errors when provider doesn't exist
  provider = aws.development
  url      = "https://token.actions.githubusercontent.com"
}

# Data source to check if GitHub OIDC provider exists - Production
data "aws_iam_openid_connect_provider" "github_existing_production" {
  count    = 0 # Temporarily disabled to avoid errors when provider doesn't exist
  provider = aws.production
  url      = "https://token.actions.githubusercontent.com"
}

# GitHub Actions OIDC Provider for Development Account
resource "aws_iam_openid_connect_provider" "github_development" {
  count = 1 # Always create since data source is disabled

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
  count = 1 # Always create since data source is disabled

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

# Data source to check if GitHubActionsSSORole exists - Development
data "aws_iam_role" "github_actions_sso_existing_development" {
  count    = 0 # Temporarily disabled to avoid errors when role doesn't exist
  provider = aws.development
  name     = "GitHubActionsSSORole"
}

# Data source to check if GitHubActionsSSORole exists - Production
data "aws_iam_role" "github_actions_sso_existing_production" {
  count    = 0 # Temporarily disabled to avoid errors when role doesn't exist
  provider = aws.production
  name     = "GitHubActionsSSORole"
}

# GitHub Actions SSO Role for Development Account
resource "aws_iam_role" "github_actions_sso_development" {
  count = 1 # Always create since data source is disabled

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

  # Ensure OIDC provider exists before creating the role
  depends_on = [aws_iam_openid_connect_provider.github_development]
}

# GitHub Actions SSO Role for Production Account
resource "aws_iam_role" "github_actions_sso_production" {
  count = 1 # Always create since data source is disabled

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

  # Ensure OIDC provider exists before creating the role
  depends_on = [aws_iam_openid_connect_provider.github_production]
}

# IAM Policy for GitHub Actions SSO Role - Development (only for newly created roles)
resource "aws_iam_role_policy" "github_actions_sso_policy_development" {
  count = 1 # Always create since data source is disabled

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

# IAM Policy for GitHub Actions SSO Role - Production (only for newly created roles)
resource "aws_iam_role_policy" "github_actions_sso_policy_production" {
  count = 1 # Always create since data source is disabled

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
  count = 1 # Always create since data source is disabled

  provider   = aws.development
  role       = aws_iam_role.github_actions_sso_development[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_role.github_actions_sso_development]
}

# Attach AdministratorAccess policy to GitHub Actions SSO Role - Production
resource "aws_iam_role_policy_attachment" "github_actions_sso_admin_production" {
  count = 1 # Always create since data source is disabled

  provider   = aws.production
  role       = aws_iam_role.github_actions_sso_production[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [aws_iam_role.github_actions_sso_production]
}

# Outputs
output "sso_enabled" {
  description = "Whether AWS SSO is enabled in this account"
  value       = local.sso_enabled
}

output "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  value       = local.sso_enabled ? local.sso_instance_arn : null
}

output "sso_enabled" {
  description = "Whether AWS SSO is enabled"
  value       = local.effective_sso_enabled
}

output "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  value       = local.effective_sso_instance_arn
}

output "identity_store_id" {
  description = "ID of the AWS Identity Store"
  value       = local.effective_identity_store_id
}

output "permission_sets" {
  description = "Created permission sets"
  value = local.effective_sso_enabled ? {
    for k, v in aws_ssoadmin_permission_set.main :
    k => {
      arn  = v.arn
      name = v.name
    }
  } : {}
}

output "user_groups" {
  description = "Created user groups in AWS Identity Store"
  value = local.effective_sso_enabled ? {
    for k, v in aws_identitystore_group.main :
    k => {
      group_id     = v.group_id
      display_name = v.display_name
      description  = v.description
    }
  } : {}
}

output "users" {
  description = "Created users in AWS Identity Store"
  value = local.effective_sso_enabled ? {
    for k, v in aws_identitystore_user.main :
    k => {
      user_id      = v.user_id
      user_name    = v.user_name
      display_name = v.display_name
      email        = v.emails[0].value
      groups       = local.users[k].groups
    }
  } : {}
}

output "account_assignments" {
  description = "Account assignments created"
  value = local.effective_sso_enabled ? {
    for k, v in aws_ssoadmin_account_assignment.main :
    k => {
      account_id     = v.target_id
      permission_set = local.account_assignments[k].permission_set
      principal_type = v.principal_type
      principal_name = local.account_assignments[k].principal_name
    }
  } : {}
}

output "sso_start_url" {
  description = "AWS SSO start URL"
  value       = local.effective_sso_enabled ? "https://${local.effective_identity_store_id}.awsapps.com/start" : null
}

output "github_actions_sso_roles" {
  description = "GitHub Actions SSO roles in each account (created or existing)"
  value = {
    development = {
      arn  = aws_iam_role.github_actions_sso_development[0].arn
      name = "GitHubActionsSSORole"
    }
    production = {
      arn  = aws_iam_role.github_actions_sso_production[0].arn
      name = "GitHubActionsSSORole"
    }
  }
}

output "github_actions_oidc_providers" {
  description = "GitHub Actions OIDC providers in each account (created or existing)"
  value = {
    development = {
      arn = aws_iam_openid_connect_provider.github_development[0].arn
      url = "https://token.actions.githubusercontent.com"
    }
    production = {
      arn = aws_iam_openid_connect_provider.github_production[0].arn
      url = "https://token.actions.githubusercontent.com"
    }
  }
}
