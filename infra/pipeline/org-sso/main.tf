terraform {
  required_providers {
    aws = {
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
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

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Create Development Account (only if not importing and not already exists)
resource "aws_organizations_account" "development" {
  count = !local.development_account_exists && var.development_account_id == "" ? 1 : 0

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
  count = !local.production_account_exists && var.production_account_id == "" ? 1 : 0

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

  development_ou_id = contains(local.existing_ou_names, "Development") ? data.aws_organizations_organizational_unit.development[0].id : aws_organizations_organizational_unit.development[0].id
  production_ou_id  = contains(local.existing_ou_names, "Production") ? data.aws_organizations_organizational_unit.production[0].id : aws_organizations_organizational_unit.production[0].id

  # Check for existing accounts by email
  existing_development_account = [for acc in data.aws_organizations_organization.main.accounts : acc if acc.email == var.development_email]
  existing_production_account  = [for acc in data.aws_organizations_organization.main.accounts : acc if acc.email == var.production_email]

  development_account_exists = length(local.existing_development_account) > 0
  production_account_exists  = length(local.existing_production_account) > 0

  # Determine account IDs
  development_account_id = local.development_account_exists ? local.existing_development_account[0].id : (var.development_account_id != "" ? var.development_account_id : aws_organizations_account.development[0].id)
  production_account_id  = local.production_account_exists ? local.existing_production_account[0].id : (var.production_account_id != "" ? var.production_account_id : aws_organizations_account.production[0].id)
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

# Data sources to check for existing IAM roles
data "aws_iam_role" "github_actions_sso_development" {
  provider = aws.development
  name     = "GitHubActionsSSORole"
}

data "aws_iam_role" "github_actions_sso_production" {
  provider = aws.production
  name     = "GitHubActionsSSORole"
}

data "aws_iam_role" "organization_access_production" {
  provider = aws.production
  name     = "OrganizationAccountAccessRole"
}

data "aws_iam_role" "organization_access_development" {
  provider = aws.development
  name     = "OrganizationAccountAccessRole"
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

  # Conditionally build managed policy attachments
  managed_policy_attachments = local.sso_enabled ? flatten([
    for ps_name, ps_config in local.permission_sets : [
      for policy_arn in ps_config.managed_policies : {
        key        = "${ps_name}-${basename(policy_arn)}"
        ps_name    = ps_name
        policy_arn = policy_arn
      }
    ]
  ]) : []

  # Conditionally build account assignments (only groups for now, users need to be created first)
  account_assignments_list = local.sso_enabled ? [
    for assignment_key, assignment_config in local.account_assignments : {
      key            = assignment_key
      account_id     = assignment_config.account_id
      ps_name        = assignment_config.permission_set
      principal_type = assignment_config.principal_type
      principal_name = assignment_config.principal_name
      is_user        = assignment_config.principal_type == "USER"
    }
  ] : []
}

# Get current account identity
data "aws_caller_identity" "current" {}

# Get AWS SSO instance (only if it exists)
data "aws_ssoadmin_instances" "main" {}

# Check if SSO is enabled
locals {
  sso_enabled       = length(data.aws_ssoadmin_instances.main.arns) > 0
  sso_instance_arn  = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.arns)[0] : null
  identity_store_id = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0] : null
}

# Create Permission Sets (only if SSO is enabled)
resource "aws_ssoadmin_permission_set" "main" {
  for_each = {
    for k, v in local.permission_sets :
    k => v
    if local.sso_enabled
  }

  name         = each.value.name
  description  = each.value.description
  instance_arn = local.sso_instance_arn

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

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.ps_name].arn
  managed_policy_arn = each.value.policy_arn
}

# Attach inline policies to permission sets
resource "aws_ssoadmin_permission_set_inline_policy" "inline_policies" {
  for_each = {
    for ps_name, ps_config in local.permission_sets :
    ps_name => ps_config
    if lookup(ps_config, "inline_policy", null) != null && local.sso_enabled
  }

  inline_policy      = each.value.inline_policy
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.key].arn
}

# Create User Groups in AWS Identity Store (only if SSO is enabled)
resource "aws_identitystore_group" "main" {
  for_each = {
    for k, v in local.user_groups :
    k => v
    if local.sso_enabled
  }

  display_name      = each.value.display_name
  description       = each.value.description
  identity_store_id = local.identity_store_id
}

# Create account assignments (only if SSO is enabled)
resource "aws_ssoadmin_account_assignment" "main" {
  for_each = {
    for item in local.account_assignments_list :
    item.key => item
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.main[each.value.ps_name].arn
  principal_type     = each.value.principal_type
  principal_id       = aws_identitystore_group.main[each.value.principal_name].group_id
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"

  # Add dependency on groups being created first
  depends_on = [aws_identitystore_group.main]
}

# Development Account Provider
provider "aws" {
  alias  = "development"
  region = var.region

  # Only assume role if we're not already in the development account
  dynamic "assume_role" {
    for_each = data.aws_caller_identity.current.account_id != local.development_account_id ? [1] : []
    content {
      role_arn = "arn:aws:iam::${local.development_account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

# Production Account Provider
provider "aws" {
  alias  = "production"
  region = var.region

  # Only assume role if we're not already in the production account
  dynamic "assume_role" {
    for_each = data.aws_caller_identity.current.account_id != local.production_account_id ? [1] : []
    content {
      role_arn = "arn:aws:iam::${local.production_account_id}:role/OrganizationAccountAccessRole"
    }
  }
}

# Create GitHubActionsSSORole in Development Account (only if it doesn't exist)
resource "aws_iam_role" "github_actions_sso_development" {
  count = try(data.aws_iam_role.github_actions_sso_development.arn, null) == null ? 1 : 0
  provider = aws.development
  name     = "GitHubActionsSSORole"

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
            "token.actions.githubusercontent.com:sub" = "repo:magebase/*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "Development"
    Purpose     = "GitHub Actions CI/CD"
    ManagedBy   = "terraform"
  }
}

# Attach AdministratorAccess policy to GitHubActionsSSORole in Development (only if role was created)
resource "aws_iam_role_policy_attachment" "github_actions_sso_development_admin" {
  count      = try(data.aws_iam_role.github_actions_sso_development.arn, null) == null ? 1 : 0
  provider   = aws.development
  role       = aws_iam_role.github_actions_sso_development[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Add inline policy for cross-account access in Development (only if role was created)
resource "aws_iam_role_policy" "github_actions_sso_development_cross_account" {
  count    = try(data.aws_iam_role.github_actions_sso_development.arn, null) == null ? 1 : 0
  provider = aws.development
  name     = "GitHubActionsSSOCrossAccountPolicy"
  role     = aws_iam_role.github_actions_sso_development[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${local.production_account_id}:role/OrganizationAccountAccessRole"
        ]
      }
    ]
  })
}

# Create GitHubActionsSSORole in Production Account (only if it doesn't exist)
resource "aws_iam_role" "github_actions_sso_production" {
  count = try(data.aws_iam_role.github_actions_sso_production.arn, null) == null ? 1 : 0
  provider = aws.production
  name     = "GitHubActionsSSORole"

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
            "token.actions.githubusercontent.com:sub" = "repo:magebase/*"
          }
        }
      }
    ]
  })

  tags = {
    Environment = "Production"
    Purpose     = "GitHub Actions CI/CD"
    ManagedBy   = "terraform"
  }
}

# Attach AdministratorAccess policy to GitHubActionsSSORole in Production (only if role was created)
resource "aws_iam_role_policy_attachment" "github_actions_sso_production_admin" {
  count      = try(data.aws_iam_role.github_actions_sso_production.arn, null) == null ? 1 : 0
  provider   = aws.production
  role       = aws_iam_role.github_actions_sso_production[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Add inline policy for cross-account access in Production (only if role was created)
resource "aws_iam_role_policy" "github_actions_sso_production_cross_account" {
  count    = try(data.aws_iam_role.github_actions_sso_production.arn, null) == null ? 1 : 0
  provider = aws.production
  name     = "GitHubActionsSSOCrossAccountPolicy"
  role     = aws_iam_role.github_actions_sso_production[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = [
          "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OrganizationAccountAccessRole",
          "arn:aws:iam::${local.development_account_id}:role/OrganizationAccountAccessRole"
        ]
      }
    ]
  })
}

# Create OrganizationAccountAccessRole in Development Account (only if it doesn't exist)
resource "aws_iam_role" "organization_access_development" {
  count    = try(data.aws_iam_role.organization_access_development.arn, null) == null && data.aws_caller_identity.current.account_id != local.development_account_id ? 1 : 0
  provider = aws.development
  name     = "OrganizationAccountAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${local.development_account_id}:role/GitHubActionsSSORole",
            "arn:aws:iam::${local.production_account_id}:role/GitHubActionsSSORole"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "Development"
    Purpose     = "AWS Organizations Access"
    ManagedBy   = "terraform"
  }
}

# Attach AdministratorAccess policy to OrganizationAccountAccessRole in Development (only if role was created)
resource "aws_iam_role_policy_attachment" "organization_access_development_admin" {
  count      = try(data.aws_iam_role.organization_access_development.arn, null) == null && data.aws_caller_identity.current.account_id != local.development_account_id ? 1 : 0
  provider   = aws.development
  role       = aws_iam_role.organization_access_development[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create OrganizationAccountAccessRole in Production Account (only if it doesn't exist)
resource "aws_iam_role" "organization_access_production" {
  count    = try(data.aws_iam_role.organization_access_production.arn, null) == null && data.aws_caller_identity.current.account_id != local.production_account_id ? 1 : 0
  provider = aws.production
  name     = "OrganizationAccountAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
            "arn:aws:iam::${local.development_account_id}:role/GitHubActionsSSORole",
            "arn:aws:iam::${local.production_account_id}:role/GitHubActionsSSORole"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "Production"
    Purpose     = "AWS Organizations Access"
    ManagedBy   = "terraform"
  }
}

# Attach AdministratorAccess policy to OrganizationAccountAccessRole in Production (only if role was created)
resource "aws_iam_role_policy_attachment" "organization_access_production_admin" {
  count      = try(data.aws_iam_role.organization_access_production.arn, null) == null && data.aws_caller_identity.current.account_id != local.production_account_id ? 1 : 0
  provider   = aws.production
  role       = aws_iam_role.organization_access_production[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
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

output "permission_sets" {
  description = "Created permission sets"
  value = local.sso_enabled ? {
    for k, v in aws_ssoadmin_permission_set.main :
    k => {
      arn  = v.arn
      name = v.name
    }
  } : {}
}

output "user_groups" {
  description = "Created user groups in AWS Identity Store"
  value = local.sso_enabled ? {
    for k, v in aws_identitystore_group.main :
    k => {
      group_id     = v.group_id
      display_name = v.display_name
      description  = v.description
    }
  } : {}
}

output "account_assignments" {
  description = "Account assignments created"
  value = local.sso_enabled ? {
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
  value       = local.sso_enabled ? "https://${local.identity_store_id}.awsapps.com/start" : null
}

output "github_actions_sso_role_development_arn" {
  description = "ARN of the GitHubActionsSSORole in the development account"
  value       = try(aws_iam_role.github_actions_sso_development[0].arn, data.aws_iam_role.github_actions_sso_development.arn)
}

output "github_actions_sso_role_production_arn" {
  description = "ARN of the GitHubActionsSSORole in the production account"
  value       = try(aws_iam_role.github_actions_sso_production[0].arn, data.aws_iam_role.github_actions_sso_production.arn)
}

output "organization_access_role_development_arn" {
  description = "ARN of the OrganizationAccountAccessRole in the development account"
  value       = try(aws_iam_role.organization_access_development[0].arn, data.aws_iam_role.organization_access_development.arn)
}

output "organization_access_role_production_arn" {
  description = "ARN of the OrganizationAccountAccessRole in the production account"
  value       = try(aws_iam_role.organization_access_production[0].arn, data.aws_iam_role.organization_access_production.arn)
}
