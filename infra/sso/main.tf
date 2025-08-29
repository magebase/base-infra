terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

# Configure the AWS Provider
provider "aws" {
  region = var.region

  # Use default credentials chain (AWS CLI, environment variables, IAM roles)
  # For SSO, you might need to configure assume_role if deploying from a different account
}

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

  # Account Assignments
  account_assignments = {
    # Management Account
    management = {
      account_id = data.aws_caller_identity.current.account_id
      assignments = [
        {
          permission_set = "administrator"
          principal_type = "USER"
          principal_name = "admin@magebase.dev"
        },
        {
          permission_set = "infrastructure"
          principal_type = "GROUP"
          principal_name = "InfrastructureTeam"
        }
      ]
    }

    # Development Account (if separate)
    development = {
      account_id = var.development_account_id
      assignments = [
        {
          permission_set = "infrastructure"
          principal_type = "GROUP"
          principal_name = "InfrastructureTeam"
        },
        {
          permission_set = "deployment"
          principal_type = "GROUP"
          principal_name = "DevelopmentTeam"
        },
        {
          permission_set = "ses"
          principal_type = "USER"
          principal_name = "ses-service@magebase.dev"
        }
      ]
    }

    # Production Account (if separate)
    production = {
      account_id = var.production_account_id
      assignments = [
        {
          permission_set = "infrastructure"
          principal_type = "GROUP"
          principal_name = "InfrastructureTeam"
        },
        {
          permission_set = "deployment"
          principal_type = "GROUP"
          principal_name = "ProductionTeam"
        },
        {
          permission_set = "readonly"
          principal_type = "GROUP"
          principal_name = "Auditors"
        }
      ]
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
}

# Get current account identity
data "aws_caller_identity" "current" {}

# Get AWS SSO instance (only if it exists)
data "aws_ssoadmin_instances" "main" {}

# Check if SSO is enabled
locals {
  sso_enabled = length(data.aws_ssoadmin_instances.main.arns) > 0
  sso_instance_arn = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.arns)[0] : null
  identity_store_id = local.sso_enabled ? tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0] : null
}

# Create Permission Sets (only if SSO is enabled)
resource "aws_ssoadmin_permission_set" "main" {
  for_each = {
    for k, v in local.permission_sets :
    k => v
    if local.sso_enabled
  }

  name        = each.value.name
  description = each.value.description
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
    for item in flatten([
      for ps_name, ps_config in local.permission_sets : [
        for policy_arn in ps_config.managed_policies : {
          key = "${ps_name}-${basename(policy_arn)}"
          permission_set_arn = aws_ssoadmin_permission_set.main[ps_name].arn
          policy_arn = policy_arn
        }
      ]
    ]) :
    item.key => item
    if local.sso_enabled
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn
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

  display_name = each.value.display_name
  description  = each.value.description
  identity_store_id = local.identity_store_id
}

# Create account assignments (only if SSO is enabled)
resource "aws_ssoadmin_account_assignment" "main" {
  for_each = {
    for item in flatten([
      for account_key, account_config in local.account_assignments : [
        for assignment in account_config.assignments : {
          key = "${account_key}-${assignment.permission_set}-${assignment.principal_type}-${assignment.principal_name}"
          account_id = account_config.account_id
          permission_set_arn = aws_ssoadmin_permission_set.main[assignment.permission_set].arn
          principal_type = assignment.principal_type
          principal_id = assignment.principal_type == "USER" ? (
            # For users, we'll need to create them separately or use existing ones
            # For now, this will need manual user creation in AWS SSO console
            "USER_ID_PLACEHOLDER_${assignment.principal_name}"
          ) : (
            aws_identitystore_group.main[assignment.principal_name].group_id
          )
        }
      ]
    ]) :
    item.key => item
    if local.sso_enabled
  }

  instance_arn       = local.sso_instance_arn
  permission_set_arn = each.value.permission_set_arn
  principal_type     = each.value.principal_type
  principal_id       = each.value.principal_id
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"

  # Add dependency on groups being created first
  depends_on = [aws_identitystore_group.main]
}

# Note: User accounts need to be created manually in AWS SSO console
# The account assignments for users use placeholder IDs that need to be updated
# with actual user IDs after user creation.

# data "aws_identitystore_user" "main" {
#   for_each = toset(flatten([
#     for account_config in values(local.account_assignments) : [
#       for assignment in account_config.assignments :
#       assignment.principal_name
#       if assignment.principal_type == "USER"
#     ]
#   ]))
#
#   identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
#
#   filter {
#     attribute_path  = "UserName"
#     attribute_value = each.key
#   }
# }

# data "aws_identitystore_group" "main" {
#   for_each = toset(flatten([
#     for account_config in values(local.account_assignments) : [
#       for assignment in account_config.assignments :
#       assignment.principal_name
#       if assignment.principal_type == "GROUP"
#     ]
#   ]))
#
#   identity_store_id = tolist(data.aws_ssoadmin_instances.main.identity_store_ids)[0]
#
#   filter {
#     attribute_path  = "DisplayName"
#     attribute_value = each.key
#   }
# }

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
      account_id        = v.target_id
      permission_set    = split("-", k)[1]
      principal_type    = v.principal_type
      principal_name    = split("-", k)[3]
    }
  } : {}
}

output "sso_start_url" {
  description = "AWS SSO start URL"
  value       = local.sso_enabled ? "https://${local.identity_store_id}.awsapps.com/start" : null
}
