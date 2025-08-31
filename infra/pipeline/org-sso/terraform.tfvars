# AWS Organizations Configuration
# Replace with your actual email addresses for account creation
# Note: These email addresses must be unique and not already used in AWS Organizations

development_email = "aws-dev-2@magebase.dev"
production_email  = "aws-prod-2@magebase.dev"

# AWS Region
region = "us-east-1" # Organizations must be in us-east-1

# Account IDs (will be populated after organizations are created)
development_account_id = ""
production_account_id  = ""

# Tags for all resources
tags = {
  Environment = "management"
  Project     = "magebase"
  ManagedBy   = "terraform"
}
