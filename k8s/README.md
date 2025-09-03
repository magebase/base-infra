   AWS_SES_ACCESS_KEY_ID_B64=base64-encoded-access-key
   AWS_SES_SECRET_ACCESS_KEY_B64=base64-encoded-secret-key
   Adjust PostgreSQL parameters in `database.yaml` based on your workload:
   Backups are automatically configured to run daily at 2 AM and stored in AWS S3.
   CREATE DATABASE magebase;
   CREATE USER magebase_user WITH PASSWORD 'your-password';
   Create a `.env` file with the following variables:
   DOMAIN=your-domain.com
   GRANT ALL PRIVILEGES ON DATABASE magebase TO magebase_user;
   HETZNER_OBJECT_STORAGE_ACCESS_KEY_B64=base64-encoded-access-key
   HETZNER_OBJECT_STORAGE_SECRET_KEY_B64=base64-encoded-secret-key
   IMAGE_NAME=magebase
   IMAGE_REGISTRY=your-registry.com
   IMAGE_TAG=latest
   RUBY_LLM_API_KEY_B64=base64-encoded-api-key
   SECRET_KEY_BASE_B64=base64-encoded-secret-key
   See the `extra-manifests/` directory in the terraform configuration for ArgoCD applications.
   The infrastructure is set up for GitOps deployments. To enable:
   This directory contains Kubernetes manifests for deploying Magebase to Hetzner Cloud k3s clusters using GitOps with ArgoCD.
# Access at http://localhost:3000
# Access at https://localhost:8443
# Application
# Application health
# Apply to cluster
# Apply to cluster
# Build the application image
# Cache uses the same database as the application (SolidCache with PostgreSQL)
# Check database logs
# Check database pod status
# Check ingress
# Check ingress status
# Check logs
# Check nginx ingress controller
# Check pod events
# Check pod status
# Check services
# Connect to PostgreSQL
# Create database and user
# Database
# Database connectivity
# Generate manifests with environment variables
# Generate manifests with environment variables
# Get Grafana admin password
# Get dashboard token
# List backup jobs
# Magebase Kubernetes Deployment
# Manual backup
# NOTE: With CloudNativePG, DATABASE_URL is automatically generated
# Navigate to dev overlay
# Navigate to prod overlay
# Port forward Grafana
# Port forward dashboard
# Push to registry
# Scale application
# Secrets (base64 encoded)
# View logs
# by the operator and stored in the 'magebase-db-creds' Kubernetes Secret
## Architecture Overview
## Backup and Recovery
## Database Management
## Deployment Instructions
## Deployment Instructions
## Directory Structure
## Directory Structure
## Environment Configurations
## GitOps with ArgoCD
## Monitoring and Observability
## Performance Tuning
## Prerequisites
## Security Considerations
## Troubleshooting
### 1. Build and Push Application Image
### 2. Deploy to Development Environment
### 3. Deploy to Production Environment
### 4. Verify Deployment
### Accessing Grafana
### Accessing Kubernetes Dashboard
### Application Backups
### Application Scaling
### Common Issues
### Database Backups
### Database Tuning
### Development
### Disaster Recovery
### Environment Variables
### Health Checks
### Initial Database Setup
### Production
### Required Tools
#### Database Connection Issues
#### Ingress Not Working
#### Pod Not Starting
- **Base Configuration**: Core application, database, and Redis manifests
- **Database**: 1 PostgreSQL instance, 5Gi storage
- **Database**: 3 PostgreSQL instances (HA), 50Gi storage
- **Database**: CloudNativePG for PostgreSQL management
- **Environment Overlays**: Development and production specific configurations
- **GitOps**: ArgoCD applications for automated deployments
- **Monitoring**: kube-prometheus-stack for observability
- **Redis**: 1 instance, 5Gi storage
- **Redis**: 2 instances for redundancy
- **Replicas**: 1 application pod
- **Replicas**: 3 application pods
- **Resources**: Higher memory/CPU limits
- **Resources**: Lower memory/CPU limits
- All secrets are stored as Kubernetes secrets
- Application logs are collected by Loki
- Database backups are automated via CloudNativePG
- Database connections use internal cluster networking
- Metrics are stored in Prometheus (configurable retention)
- Network policies should be implemented for production
- TLS certificates are managed by cert-manager
- `docker` for building application images
- `effective_cache_size`
- `helm` for additional component installations
- `kubectl` configured to access your k3s cluster
- `kustomize` for manifest customization
- `maintenance_work_mem`
- `max_connections`
- `shared_buffers`
1. Configure ArgoCD to watch this repository
1. Configure deployment approvals for production
1. Redeploy application from Git
1. Restore any persistent volumes if needed
1. Restore from database backup
1. Set up automatic image updates
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
```
````
````bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
```bash
cd k8s/overlays/dev
cd k8s/overlays/prod
curl https://your-domain.com/health
docker build -t $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG .
docker push $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG
k8s/
kubectl -n kubernetes-dashboard create token admin-user
kubectl apply -f dev-manifests.yaml
kubectl apply -f prod-manifests.yaml
kubectl create job --from=cronjob/magebase-db-backup manual-backup-001 -n magebase-prod
kubectl describe ingress magebase-ingress -n magebase-prod
kubectl describe pod <pod-name> -n magebase-prod
kubectl exec -it magebase-app-<pod-id> -n magebase-prod -- rails db:version
kubectl exec -it magebase-db-1 -n magebase-prod -- psql -U postgres
kubectl get ingress -n magebase-dev
kubectl get pods -l app.kubernetes.io/name=cloudnative-pg -n magebase-prod
kubectl get pods -n kube-system -l app.kubernetes.io/name=ingress-nginx
kubectl get pods -n magebase-dev  # or magebase-prod
kubectl get scheduledbackup -n magebase-prod
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
kubectl get services -n magebase-dev
kubectl logs -f deployment/magebase-app -n magebase-dev
kubectl logs -l app.kubernetes.io/name=cloudnative-pg -n magebase-prod
kubectl logs <pod-name> -n magebase-prod
kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n monitoring
kubectl port-forward svc/kubernetes-dashboard-kong-proxy 8443:443 -n kubernetes-dashboard
kubectl scale deployment magebase-app --replicas=5 -n magebase-prod
kustomize build . | envsubst > dev-manifests.yaml
kustomize build . | envsubst > prod-manifests.yaml
│       └── prod-patches.yaml
│       ├── kustomization.yaml
│   │   └── dev-patches.yaml
│   │   ├── kustomization.yaml
│   └── kustomization.yaml  # Base kustomization
│   └── prod/              # Production environment
│   ├── database.yaml       # PostgreSQL cluster
│   ├── deployment.yaml     # Application deployment
│   ├── dev/               # Development environment
│   ├── redis.yaml          # Redis cache
└── README.md              # This file
├── base/                    # Base Kubernetes manifests
├── overlays/               # Environment-specific overlays
