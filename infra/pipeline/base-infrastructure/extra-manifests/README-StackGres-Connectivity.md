# StackGres Database Connectivity Solution

This document provides a comprehensive overview of the multi-client StackGres database connectivity solution implemented in the Magebase infrastructure.

## Overview

The solution provides a scalable, secure, and automated way for multiple clients to connect to their dedicated StackGres Citus database clusters across different environments (dev, qa, uat, prod).

## Architecture

### Components

1. **StackGres Operator**: Manages PostgreSQL clusters with Citus extension
2. **AWS SSM Parameter Store**: Centralized secure storage for database URLs
3. **External Secrets Operator (ESO)**: Syncs SSM parameters to Kubernetes secrets
4. **ArgoCD ApplicationSets**: Automated deployment across client-environment combinations
5. **KEDA**: Event-driven autoscaling for scale-to-zero functionality
6. **GitHub Actions**: Automated credential synchronization

### Data Flow

```text
StackGres Cluster → Database URL Secret → SSM Parameter Store → External Secrets → Application Pods
```

## Infrastructure Setup

### Base Infrastructure Files

#### 1. Client Configuration (`clients.json`)

```json
[
  "genfix",
  "site"
]
```

#### 2. Terraform SSM Management (`main.tf`)

- Creates SSM parameters for all client-environment combinations
- Format: `/client/environment/database/url`

#### 3. Base Infrastructure Pipeline (`.github/workflows/base-infrastructure.yml`)

- **Integrated Terraform Deployment**: Deploys database clusters and infrastructure with automatic SSM parameter synchronization
- **No Separate Steps**: SSM parameters are updated automatically as part of the Terraform deployment process
- **Atomic Operations**: Infrastructure deployment and SSM sync happen together, eliminating race conditions
- **StackGres Readiness**: Deployment commands wait for StackGres operator and clusters to be ready before syncing SSM parameters

#### 4. ArgoCD ApplicationSet (`extra-manifests/argocd-applicationset.yaml`)

- Generates applications for all client-environment combinations
- Automates deployment of database clusters

#### 5. External Secrets Templates

- `external-secret-template.yaml.tpl`: Template for ExternalSecret resources
- `secret-store.yaml.tpl`: AWS SSM SecretStore configuration

#### 6. KEDA Scaling Templates

- `keda-scaledobject-template.yaml.tpl`: Scale-to-zero configuration

### Cluster Configurations

#### Environment-Specific Clusters

- `genfix/dev-cluster.yaml.tpl`
- `genfix/qa-cluster.yaml.tpl`
- `genfix/uat-cluster.yaml.tpl`
- `genfix/prod-cluster.yaml.tpl`
- `site/dev-cluster.yaml.tpl`
- `site/qa-cluster.yaml.tpl`
- `site/uat-cluster.yaml.tpl`
- `site/prod-cluster.yaml.tpl`

Each cluster includes:

- ExternalSecret for SSM parameter access
- KEDA ScaledObject for autoscaling
- Minimum resource specifications
- Unified Cloudflare R2 backup storage

## Client Repository Setup

### Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`: AWS access key with SSM read permissions
- `AWS_SECRET_ACCESS_KEY`: AWS secret key with SSM read permissions
- `ARGOCD_TOKEN`: ArgoCD token for triggering deployments

### Required GitHub Variables

- `AWS_REGION`: AWS region (e.g., us-east-1)
- `ENVIRONMENT`: Environment name (dev, qa, uat, prod)

### Example Application Configuration

#### Knative Service

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: client-app
  namespace: client-ns
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "0"
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
      - name: app
        image: client-app:latest
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: magebase-app-secrets
              key: DATABASE_URL
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

#### GitHub Actions Build Workflow

```yaml
name: Build and Test
on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ vars.AWS_REGION }}

    - name: Fetch DATABASE_URL from SSM
      run: |
        DATABASE_URL=$(aws ssm get-parameter \
          --name "/client/${{ vars.ENVIRONMENT }}/${{ github.repository_owner }}/database/url" \
          --with-decryption \
          --query Parameter.Value \
          --output text)
        echo "DATABASE_URL=$DATABASE_URL" >> $GITHUB_ENV

    - name: Build application
      env:
        DATABASE_URL: ${{ env.DATABASE_URL }}
      run: |
        # Build commands here
```

## Security Considerations

### Credential Management

- Database credentials are automatically rotated by StackGres
- SSM Parameter Store provides centralized secure storage
- External Secrets Operator syncs credentials to Kubernetes
- No hardcoded secrets in application code

### Access Control

- SSM parameters are scoped by client and environment
- AWS IAM policies control access to SSM parameters
- Kubernetes RBAC controls access to secrets

## Scaling and Cost Optimization

### Autoscaling

- KEDA enables scale-to-zero functionality
- Minimum scale: 0 pods (when no traffic)
- Maximum scale: 10 pods (configurable)
- Scales based on CPU utilization and request rate

### Resource Optimization

- Minimum resource specifications across all environments
- Pay-as-you-go model with scale-to-zero
- Shared infrastructure reduces operational overhead

## Monitoring and Observability

### StackGres Monitoring

- Prometheus metrics collection
- Grafana dashboards for database monitoring
- Alerting rules for database health

### Application Monitoring

- Knative service metrics
- KEDA scaling metrics
- Application performance monitoring

## Deployment Process

### Automated Deployment

1. ArgoCD ApplicationSet creates applications for all combinations
2. StackGres operator deploys database clusters
3. **Integrated SSM Sync**: Terraform deployment commands automatically wait for StackGres readiness and sync database URLs to SSM Parameter Store
4. External Secrets sync SSM parameters to Kubernetes secrets
5. KEDA configures autoscaling
6. Applications deploy with database connectivity

### Manual Deployment

1. Update client list in `clients.json`
2. Run Terraform deployment (includes automatic SSM parameter synchronization)
3. Deploy via ArgoCD or kubectl
4. Configure client repository with required secrets

## Troubleshooting

### Common Issues

#### SSM Parameter Not Found

- Verify AWS credentials have SSM read permissions
- Check parameter path format: `/client/environment/database/url`
- Ensure SSM parameter exists in correct region

#### External Secret Not Syncing

- Check External Secrets Operator status
- Verify SecretStore configuration
- Check AWS IAM permissions

#### Database Connection Failed

- Verify DATABASE_URL format
- Check StackGres cluster status
- Validate network connectivity

### Debugging Commands

```bash
# Check SSM parameter
aws ssm get-parameter --name "/client/dev/database/url" --with-decryption

# Check External Secret status
kubectl get externalsecret -n client-ns

# Check KEDA ScaledObject
kubectl get scaledobject -n client-ns

# Check StackGres cluster
kubectl get sgcluster -n client-ns
```

## Future Enhancements

### Planned Improvements

- Multi-region deployment support
- Database backup automation
- Enhanced monitoring dashboards
- Automated failover configuration
- Database migration tooling

### Extension Points

- Custom resource definitions for client-specific configurations
- Integration with additional secret stores (Vault, GCP Secret Manager)
- Advanced scaling policies based on business metrics
- Database performance optimization recommendations
