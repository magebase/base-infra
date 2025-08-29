# Development Environment Variables
# NOTE: Sensitive values are loaded from GitHub Secrets, not stored in this file

# Environment
environment = "dev"

# Domain Configuration
domain_name = "magebase.dev"

# AWS Organizations Configuration
development_email = "magebase.dev+development@gmail.com"
production_email  = "magebase.dev+production@gmail.com"

# Docker Configuration
docker_image = "magebase/site:dev-latest"

# Infrastructure Configuration
# These values are loaded from environment variables in CI/CD:
# - hcloud_token: From HCLOUD_TOKEN secret
# - cloudflare_api_token: From CLOUDFLARE_API_TOKEN secret
# - aws_ses_account_id: From AWS_SES_ACCOUNT_ID secret
# - database_url: From DATABASE_URL secret
# - cache_database_url: From CACHE_DATABASE_URL secret
# - secret_key_base: From SECRET_KEY_BASE secret
# - ruby_llm_api_key: From RUBY_LLM_API_KEY secret
# - aws_ses_access_key_id: From AWS_SES_ACCESS_KEY_ID secret
# - aws_ses_secret_access_key: From AWS_SES_SECRET_ACCESS_KEY secret
# - stripe_api_key: From STRIPE_API_KEY secret
# - stripe_webhook_secret: From STRIPE_WEBHOOK_SECRET secret
# - ssh_private_key: From SSH_PRIVATE_KEY secret
# - ssh_public_key: From SSH_PUBLIC_KEY secret
