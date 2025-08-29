# QA Environment Variables
# Replace placeholder values with your actual configuration

# AWS Management Account ID - Your root AWS account ID for Organizations
management_account_id = "123456789012"

# Database Configuration
# PostgreSQL connection string for the RDS database (used for both main data and SolidCache)
database_url = "postgresql://magebase_admin:your_password_here@magebase-postgres.cluster-xxxxxx.ap-southeast-2.rds.amazonaws.com:5432/magebase_qa"

# Cache Configuration
# SolidCache uses PostgreSQL for caching (can use same as database_url or separate)
cache_database_url = "postgresql://magebase_admin:your_password_here@magebase-postgres.cluster-xxxxxx.ap-southeast-2.rds.amazonaws.com:5432/magebase_qa"

# Rails Application Secrets
# Secret key base for Rails sessions and encrypted cookies
secret_key_base = "your-qa-secret-key-base-here-32-characters-minimum"

# AI Service Configuration
# API key for RubyLLM service (AI-powered pricing and contract generation)
ruby_llm_api_key = "your-ruby-llm-api-key-here"

# Docker Configuration
# Docker image tag for App Runner deployments
docker_image_tag = "qa-latest"
