# Terraform Infrastructure

This directory contains the Terraform configuration for deploying Magebase infrastructure to Hetzner Cloud with k3s clusters.

## 🔒 Security First

**All sensitive values are loaded from GitHub Secrets, never stored in tfvars files.**

## 📁 Directory Structure

```
terraform/
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── dev.tfvars             # Development environment (no secrets)
├── prod.tfvars            # Production environment (no secrets)
├── terraform.tfvars.example # Template for creating tfvars files
├── modules/
│   ├── cloudflare/        # Cloudflare DNS configuration
│   └── aws-ses/          # AWS SES email service
└── extra-manifests/      # ArgoCD applications
```

## 🚀 Quick Start

### 1. Prerequisites

- Terraform 1.5.0+
- GitHub repository with secrets configured
- Hetzner Cloud account with API token
- Cloudflare account with API token
- AWS account with SES access

### 2. Configure GitHub Secrets

Add the following secrets to your GitHub repository:

```bash
# Required Secrets
HCLOUD_TOKEN=your-hetzner-api-token
CLOUDFLARE_API_TOKEN=your-cloudflare-api-token
AWS_SES_ACCOUNT_ID=your-aws-account-id
AWS_SES_ACCESS_KEY_ID=your-ses-access-key-id
AWS_SES_SECRET_ACCESS_KEY=your-ses-secret-access-key

# Application Secrets
DATABASE_URL=postgresql://user:password@host:5432/database
CACHE_DATABASE_URL=redis://host:6379/0
SECRET_KEY_BASE=your-32-character-secret-key
RUBY_LLM_API_KEY=your-ruby-llm-api-key

# Optional Secrets
DOMAIN_NAME=magebase.dev
STRIPE_API_KEY=sk_test_your-stripe-key
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret
```

### 3. Deploy Infrastructure

#### Using GitHub Actions (Recommended)

```bash
# Trigger deployment via GitHub Actions
# Go to Actions → Terraform Infrastructure Deployment
# Choose environment (dev/prod) and action (plan/apply)
```

#### Manual Deployment

```bash
# Set environment variables
export TF_VAR_hcloud_token="your-token"
export TF_VAR_cloudflare_api_token="your-token"
# ... set all required variables

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="dev.tfvars"

# Apply changes
terraform apply -var-file="dev.tfvars"
```

## 🏗️ Infrastructure Components

### Hetzner Cloud k3s Clusters

- **Development**: 1 control plane + 1 agent node
- **Production**: 3 control plane + 3 agent nodes (HA)
- **Networking**: Cilium CNI with Hubble observability
- **Load Balancing**: Hetzner load balancers

### Cloudflare DNS

- **Free Plan**: DNS management for magebase.dev
- **Proxied Records**: CDN and security benefits
- **Automatic SSL**: Free SSL certificates

### AWS SES Integration

- **Email Service**: Maintained from legacy AWS setup
- **SMTP Configuration**: For transactional emails
- **DKIM/SPF**: Email authentication

### Monitoring Stack

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **AlertManager**: Alert management
- **CloudNativePG**: Database monitoring

## 🔧 Configuration

### Environment Variables

All sensitive configuration is handled through environment variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `TF_VAR_hcloud_token` | Hetzner Cloud API token | Yes |
| `TF_VAR_cloudflare_api_token` | Cloudflare API token | Yes |
| `TF_VAR_aws_ses_account_id` | AWS account ID | Yes |
| `TF_VAR_database_url` | PostgreSQL connection URL | Yes |
| `TF_VAR_secret_key_base` | Rails secret key | Yes |
| `TF_VAR_ruby_llm_api_key` | AI service API key | Yes |
| `TF_VAR_domain_name` | Application domain | No |

### tfvars Files

The `dev.tfvars` and `prod.tfvars` files contain only non-sensitive configuration:

```hcl
# dev.tfvars
environment = "dev"
domain_name = "magebase.dev"
docker_image = "magebase/site:dev-latest"
```

## 🚦 GitHub Actions Workflows

### Terraform Infrastructure Deployment

**Trigger**: Manual or push to main
**Actions**: plan, apply, destroy
**Environments**: dev, prod

Features:
- ✅ Secure secret handling
- ✅ Environment-specific deployments
- ✅ Plan review before apply
- ✅ PR comments with plan output
- ✅ Deployment summaries

### Infrastructure Validation

**Trigger**: Push/PR to main, changes to terraform/
**Actions**: format, validate, security scan

## 🔍 Troubleshooting

### Common Issues

#### Authentication Errors

```bash
# Check GitHub secrets are set
gh secret list

# Verify environment variables in workflow
# Check workflow logs for TF_VAR_* variables
```

#### Terraform State

```bash
# Initialize backend
terraform init

# Check state
terraform state list

# Fix state issues
terraform refresh
```

#### DNS Issues

```bash
# Check Cloudflare records
nslookup magebase.dev

# Verify DNS propagation
dig magebase.dev
```

### Debugging

```bash
# Enable debug logging
export TF_LOG=DEBUG

# Plan with debug
terraform plan -var-file="dev.tfvars"

# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces
```

## 📊 Cost Optimization

### Hetzner Cloud Pricing

- **CX11**: €3.85/month (dev environment)
- **CX31**: €7.70/month (prod control plane)
- **CX32**: €15.40/month (prod agents)

### AWS Costs (SES Only)

- **Free Tier**: 62,000 emails/month
- **Pay-as-you-go**: $0.10/1000 emails

## 🔐 Security Best Practices

### Secrets Management

- ✅ All secrets in GitHub Secrets
- ✅ No sensitive data in tfvars files
- ✅ Environment-specific secret access
- ✅ Audit logs for secret access

### Network Security

- ✅ Private networking between nodes
- ✅ Firewall rules for Hetzner
- ✅ Cloudflare WAF protection
- ✅ TLS encryption for all traffic

### Access Control

- ✅ GitHub Actions OIDC for AWS
- ✅ Least privilege IAM roles
- ✅ API token rotation
- ✅ Audit trails

## 📝 Development Workflow

### Making Changes

1. **Local Testing**
   ```bash
   # Format code
   terraform fmt

   # Validate configuration
   terraform validate

   # Plan changes
   terraform plan -var-file="dev.tfvars"
   ```

2. **Create Pull Request**
   ```bash
   git checkout -b feature/terraform-update
   git add .
   git commit -m "feat: update terraform configuration"
   git push origin feature/terraform-update
   ```

3. **Review and Deploy**
   - GitHub Actions will validate changes
   - Review plan output in PR comments
   - Manual approval for production deployment

### Environment Management

```bash
# Development deployment
gh workflow run "Terraform Infrastructure Deployment" \
  --field environment=dev \
  --field action=apply

# Production deployment
gh workflow run "Terraform Infrastructure Deployment" \
  --field environment=prod \
  --field action=apply
```

## 📚 Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [Hetzner Cloud API](https://docs.hetzner.cloud/)
- [Cloudflare API](https://api.cloudflare.com/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

## 🤝 Contributing

1. Follow security best practices
2. Test changes in development first
3. Update documentation
4. Use conventional commits
5. Get approval for production changes

---

**Remember**: Never commit sensitive values to the repository. Always use GitHub Secrets for sensitive configuration.
