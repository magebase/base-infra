# Terragrunt configuration for base infrastructure
# This includes the org-sso setup and bootstrap steps

remote_state {
  backend = "s3"
  config = {
    bucket         = "magebase-tf-state-management-ap-southeast-1"
    key            = "magebase/base-infrastructure/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "magebase-terraform-locks-management"
  }
}

# Include the org-sso configuration
dependency "org_sso" {
  config_path = "../org-sso"

  mock_outputs = {
    development_account_id = "123456789012"
    production_account_id  = "123456789013"
    qa_account_id         = "123456789014"
    uat_account_id        = "123456789015"
  }
}

# Include bootstrap configuration
dependency "bootstrap" {
  config_path = "../bootstrap"

  mock_outputs = {
    state_bucket      = "magebase-tf-state-management-ap-southeast-1"
    dynamodb_table    = "magebase-terraform-locks-management"
    state_bucket_arn  = "arn:aws:s3:::magebase-tf-state-management-ap-southeast-1"
    dynamodb_table_arn = "arn:aws:dynamodb:ap-southeast-1:123456789012:table/magebase-terraform-locks-management"
  }
}

# Generate provider configuration
generate "provider" {
  path = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.52.0"
    }
  }
}

# AWS provider for management account
provider "aws" {
  alias  = "management"
  region = var.aws_region
}

# AWS provider for development account
provider "aws" {
  alias  = "development"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${dependency.org_sso.outputs.development_account_id}:role/OrganizationAccountAccessRole"
  }
}

# AWS provider for production account
provider "aws" {
  alias  = "production"
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${dependency.org_sso.outputs.production_account_id}:role/OrganizationAccountAccessRole"
  }
}

# Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}
EOF
}

inputs = {
  # AWS Configuration
  aws_region = "ap-southeast-1"

  # Hetzner Configuration
  hcloud_token = get_env("HCLOUD_TOKEN", "")

  # Infrastructure Configuration
  environment = get_env("ENVIRONMENT", "dev")
  domain = get_env("DOMAIN", "dev.magebase.dev")

  # SSH Keys
  ssh_public_key = get_env("SSH_PUBLIC_KEY", "")
  ssh_private_key = get_env("SSH_PRIVATE_KEY", "")

  # Security
  argocd_admin_password = get_env("ARGOCD_ADMIN_PASSWORD", "")
  encryption_key = get_env("ENCRYPTION_KEY", "")
  cloudflare_api_token = get_env("CLOUDFLARE_API_TOKEN", "")

  # Cloudflare R2 Configuration
  cloudflare_r2_access_key_id = get_env("CLOUDFLARE_R2_ACCESS_KEY_ID", "")
  cloudflare_r2_secret_access_key = get_env("CLOUDFLARE_R2_SECRET_ACCESS_KEY", "")

  # Account IDs from org-sso
  development_account_id = dependency.org_sso.outputs.development_account_id
  production_account_id  = dependency.org_sso.outputs.production_account_id
  qa_account_id         = dependency.org_sso.outputs.qa_account_id
  uat_account_id        = dependency.org_sso.outputs.uat_account_id

  # Bootstrap outputs
  state_bucket   = dependency.bootstrap.outputs.state_bucket
  dynamodb_table = dependency.bootstrap.outputs.dynamodb_table
}
