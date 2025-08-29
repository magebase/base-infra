# Terragrunt configuration for prod environment
include "root" {
  path = find_in_parent_folders()
}

locals {
  environment = "prod"
  domain_name = "magebase.dev"
}

inputs = {
  environment = local.environment
  domain_name = local.domain_name

  fly_org             = get_env("FLY_ORG", "magebase")
  fly_region          = "syd"
  aws_region          = "us-east-1"

  database_url        = get_env("DATABASE_URL", "")
  redis_url          = get_env("REDIS_URL", "")
  secret_key_base    = get_env("SECRET_KEY_BASE", "")
  ruby_llm_api_key   = get_env("RUBY_LLM_API_KEY", "")
  aws_ses_access_key_id = get_env("AWS_SES_ACCESS_KEY_ID", "")
  aws_ses_secret_access_key = get_env("AWS_SES_SECRET_ACCESS_KEY", "")
  docker_image       = "magebase/site:prod-${get_env("GITHUB_SHA", "latest")}"
}
