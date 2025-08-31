# Magebase Kubernetes Deployment

This directory contains Kubernetes manifests for deploying Magebase to Hetzner Cloud k3s clusters using GitOps with ArgoCD.

## Architecture Overview

- **Base Configuration**: Core application, database, and Redis manifests
- **Environment Overlays**: Development and production specific configurations
- **GitOps**: ArgoCD applications for automated deployments
- **Monitoring**: kube-prometheus-stack for observability
- **Database**: CloudNativePG for PostgreSQL management

## Prerequisites

### Required Tools

- `kubectl` configured to access your k3s cluster
- `kustomize` for manifest customization
- `docker` for building application images
- `helm` for additional component installations

### Environment Variables

Create a `.env` file with the following variables:

```bash
# Application
IMAGE_REGISTRY=your-registry.com
IMAGE_NAME=magebase
IMAGE_TAG=latest
DOMAIN=your-domain.com

# Database
DATABASE_URL=postgresql://user:password@magebase-db-rw:5432/magebase
# Cache uses the same database as DATABASE_URL (SolidCache with PostgreSQL)

# Secrets (base64 encoded)
SECRET_KEY_BASE_B64=base64-encoded-secret-key
RUBY_LLM_API_KEY_B64=base64-encoded-api-key
AWS_SES_ACCESS_KEY_ID_B64=base64-encoded-access-key
AWS_SES_SECRET_ACCESS_KEY_B64=base64-encoded-secret-key
HETZNER_OBJECT_STORAGE_ACCESS_KEY_B64=base64-encoded-access-key
HETZNER_OBJECT_STORAGE_SECRET_KEY_B64=base64-encoded-secret-key
```

## Directory Structure

## Directory Structure

```
k8s/
├── base/                    # Base Kubernetes manifests
│   ├── deployment.yaml     # Application deployment
│   ├── database.yaml       # PostgreSQL cluster
│   ├── redis.yaml          # Redis cache
│   └── kustomization.yaml  # Base kustomization
├── overlays/               # Environment-specific overlays
│   ├── dev/               # Development environment
│   │   ├── kustomization.yaml
│   │   └── dev-patches.yaml
│   └── prod/              # Production environment
│       ├── kustomization.yaml
│       └── prod-patches.yaml
└── README.md              # This file
```

## Deployment Instructions

## Deployment Instructions

### 1. Build and Push Application Image

```bash
# Build the application image
docker build -t $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG .

# Push to registry
docker push $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
```

### 2. Deploy to Development Environment

```bash
# Navigate to dev overlay
cd k8s/overlays/dev

# Generate manifests with environment variables
kustomize build . | envsubst > dev-manifests.yaml

# Apply to cluster
kubectl apply -f dev-manifests.yaml
```

### 3. Deploy to Production Environment

```bash
# Navigate to prod overlay
cd k8s/overlays/prod

# Generate manifests with environment variables
kustomize build . | envsubst > prod-manifests.yaml

# Apply to cluster
kubectl apply -f prod-manifests.yaml
```

### 4. Verify Deployment

```bash
# Check pod status
kubectl get pods -n magebase-dev  # or magebase-prod

# Check services
kubectl get services -n magebase-dev

# Check ingress
kubectl get ingress -n magebase-dev

# View logs
kubectl logs -f deployment/magebase-app -n magebase-dev
```

## Environment Configurations

### Development

- **Replicas**: 1 application pod
- **Database**: 1 PostgreSQL instance, 5Gi storage
- **Redis**: 1 instance, 5Gi storage
- **Resources**: Lower memory/CPU limits

### Production

- **Replicas**: 3 application pods
- **Database**: 3 PostgreSQL instances (HA), 50Gi storage
- **Redis**: 2 instances for redundancy
- **Resources**: Higher memory/CPU limits

## Database Management

### Initial Database Setup

```bash
# Connect to PostgreSQL
kubectl exec -it magebase-db-1 -n magebase-prod -- psql -U postgres

# Create database and user
CREATE DATABASE magebase;
CREATE USER magebase_user WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE magebase TO magebase_user;
```

### Database Backups

Backups are automatically configured to run daily at 2 AM and stored in AWS S3.

```bash
# List backup jobs
kubectl get scheduledbackup -n magebase-prod

# Manual backup
kubectl create job --from=cronjob/magebase-db-backup manual-backup-001 -n magebase-prod
```

## Monitoring and Observability

### Accessing Grafana

```bash
# Get Grafana admin password
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring

# Access at http://localhost:3000
```

### Accessing Kubernetes Dashboard

```bash
# Get dashboard token
kubectl -n kubernetes-dashboard create token admin-user

# Port forward dashboard
kubectl port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 -n kubernetes-dashboard

# Access at https://localhost:8443
```

## Troubleshooting

### Common Issues

#### Pod Not Starting

```bash
# Check pod events
kubectl describe pod <pod-name> -n magebase-prod

# Check logs
kubectl logs <pod-name> -n magebase-prod
```

#### Database Connection Issues

```bash
# Check database pod status
kubectl get pods -l app.kubernetes.io/name=cloudnative-pg -n magebase-prod

# Check database logs
kubectl logs -l app.kubernetes.io/name=cloudnative-pg -n magebase-prod
```

#### Ingress Not Working

```bash
# Check ingress status
kubectl describe ingress magebase-ingress -n magebase-prod

# Check nginx ingress controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=ingress-nginx
```

### Health Checks

```bash
# Application health
curl https://your-domain.com/health

# Database connectivity
kubectl exec -it magebase-app-<pod-id> -n magebase-prod -- rails db:version
```

## Security Considerations

- All secrets are stored as Kubernetes secrets
- Database connections use internal cluster networking
- TLS certificates are managed by cert-manager
- Network policies should be implemented for production

## Performance Tuning

### Application Scaling

```bash
# Scale application
kubectl scale deployment magebase-app --replicas=5 -n magebase-prod
```

### Database Tuning

Adjust PostgreSQL parameters in `database.yaml` based on your workload:

- `max_connections`
- `shared_buffers`
- `effective_cache_size`
- `maintenance_work_mem`

## Backup and Recovery

### Application Backups

- Database backups are automated via CloudNativePG
- Application logs are collected by Loki
- Metrics are stored in Prometheus (configurable retention)

### Disaster Recovery

1. Restore from database backup
2. Redeploy application from Git
3. Restore any persistent volumes if needed

## GitOps with ArgoCD

The infrastructure is set up for GitOps deployments. To enable:

1. Configure ArgoCD to watch this repository
2. Set up automatic image updates
3. Configure deployment approvals for production

See the `extra-manifests/` directory in the terraform configuration for ArgoCD applications.
