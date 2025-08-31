# AWS Organizations Configuration
# Replace with your actual email addresses for account creation
# Note: These email addresses must be unique and not already used in AWS Organizations

development_email = "aws-dev@magebase.dev"
production_email  = "aws-prod@magebase.dev"

# AWS Region
region = "us-east-1" # Organizations must be in us-east-1

# Account IDs (populate these with your existing account IDs)
development_account_id = "308488080915"
production_account_id  = ""

# Cloudflare Configuration
cloudflare_zone_id = ""  # Add your Cloudflare zone ID for magebase.dev

# Tags for all resources
tags = {
  Environment = "management"
  Project     = "magebase"
  ManagedBy   = "terraform"
}
