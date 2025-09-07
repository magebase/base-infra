# External Secrets Operator (ESO) with AWS Parameter Store

This directory contains the configuration for External Secrets Operator (ESO) with AWS Parameter Store integration for secure secret management across client applications.

## Overview

The setup provides:

- **Scoped IAM roles** for each client with access only to their parameters
- **AWS Parameter Store** integration for storing secrets
- **Kustomize** templates for easy deployment
- **Terraform** modules for IAM role and policy management

## Architecture

```mermaid
Client Application
        ↓
ExternalSecret (references SecretStore)
        ↓
SecretStore (with scoped IAM role)
        ↓
AWS Parameter Store (scoped to client)
```

## Directory Structure

```
eso/
├── kustomization.yaml.tpl          # ESO installation and configuration
├── namespace.yaml.tpl              # ESO namespace
├── aws-secret-store.yaml.tpl       # Base AWS credentials and SecretStore
├── client-secret-stores.yaml.tpl   # Client-specific SecretStores with scoped roles
└── external-secret-examples.yaml.tpl # Example ExternalSecret templates
```

## AWS IAM Setup

### 1. Create IAM Roles and Policies

Use the Terraform module in `modules/external-secrets-roles/`:

```hcl
module "external_secrets_roles" {
  source = "./modules/external-secrets-roles"

  external_secrets_trust_account_arn = "arn:aws:iam::123456789012:root"
  client_name = "my-client"

  tags = {
    Environment = "production"
    Project     = "magebase"
  }
}
```

### 4. ExternalSecret Example

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: genfix-database-secret
  namespace: genfix
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: genfix-secret-store
    kind: SecretStore
  target:
    name: database-secret
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: /genfix/dev/database/username
  - secretKey: password
    remoteRef:
      key: /genfix/dev/database/password
```

### 5. Terraform Module Usage

```hcl
module "external_secrets_roles" {
  source = "./modules/external-secrets-roles"

  for_each = toset(["genfix", "site"])

  client_name = each.key
  environment = "dev"
  region      = "us-east-1"
}
```

### 3. IAM Policy Example

Each client gets a scoped policy like:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameter*",
        "ssm:DescribeParameters"
      ],
      "Resource": "arn:aws:ssm:us-east-1:123456789012:parameter/genfix/*"
    }
  ]
}
```

## Usage

### 1. Deploy ESO

The ESO is included in the main kustomization and will be deployed automatically.

### 2. Create Client SecretStore

For each client, create a SecretStore with their scoped role:

```yaml
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: myclient-secret-store
  namespace: external-secrets-system
spec:
  provider:
    aws:
      service: ParameterStore
      region: us-east-1
      role: arn:aws:iam::123456789012:role/external-secrets-myclient
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
```

### 3. Create ExternalSecret

In your application namespace, create ExternalSecrets:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: myclient-dev
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: myclient-secret-store
    kind: SecretStore
  target:
    name: database-credentials
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: /myclient/dev/database/username
  - secretKey: password
    remoteRef:
      key: /myclient/dev/database/password
```

## Environment Variables

Set these environment variables for the templates:

- `AWS_ACCESS_KEY_ID`: AWS access key for ESO
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for ESO
- `AWS_REGION`: AWS region (e.g., us-east-1)
- `AWS_ACCOUNT_ID`: AWS account ID
- `CLIENT_NAME`: Client name for template substitution
- `ENVIRONMENT`: Environment (dev, staging, prod)

## Security Considerations

1. **Principle of Least Privilege**: Each client only has access to their parameters
2. **Scoped IAM Roles**: Roles are limited to specific parameter paths
3. **Regular Rotation**: Rotate AWS credentials regularly
4. **Audit Logging**: Enable CloudTrail for Parameter Store access
5. **Encryption**: Use KMS keys for sensitive parameters

## Monitoring

Monitor ESO with:

```bash
# Check ESO pods
kubectl get pods -n external-secrets-system

# Check ExternalSecret status
kubectl get externalsecret -A

# Check SecretStore status
kubectl get secretstore -n external-secrets-system
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Check IAM role policies and trust relationships
2. **Parameter Not Found**: Verify parameter paths in Parameter Store
3. **Timeout Errors**: Check network connectivity and AWS credentials
4. **CRD Not Found**: Ensure ESO is properly installed

### Debug Commands

```bash
# Check ESO logs
kubectl logs -n external-secrets-system deployment/external-secrets-webhook

# Describe ExternalSecret
kubectl describe externalsecret my-secret -n my-namespace

# Check AWS credentials
kubectl get secret awssm-secret -n external-secrets-system -o yaml
```

## Adding New Clients

1. Create IAM role and policy using Terraform module
2. Add client-specific SecretStore to `client-secret-stores.yaml.tpl`
3. Create ExternalSecrets in client application manifests
4. Update parameter paths in AWS Parameter Store

## Cost Considerations

- SSM Parameter Store charges per API call
- Standard parameters: $0.05 per 10,000 calls
- Advanced parameters: $0.05 per 10,000 calls + storage costs
- Monitor usage in AWS Cost Explorer
