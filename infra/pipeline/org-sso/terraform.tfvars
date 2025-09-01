# AWS Organizations Configuration
# Replace with your actual email addresses for account creation
# Note: These email addresses must be unique and not already used in AWS Organizations

development_email = "aws-dev@magebase.dev"
production_email  = "aws-prod@magebase.dev"

# AWS Region
region = "us-east-1" # Organizations must be in us-east-1

# Account IDs (leave empty to auto-detect existing accounts or create new ones)
development_account_id = ""
production_account_id  = ""

# Cloudflare Configuration
# These values are now passed via GitHub secrets as environment variables
# TF_VAR_cloudflare_api_token and TF_VAR_cloudflare_zone_id
# No need to set them here as they will be overridden by environment variables
