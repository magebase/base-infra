# ArgoCD App-of-Apps Pattern

This directory implements the ArgoCD app-of-apps pattern for managing all infrastructure and client applications.

## Structure

```bash
extra-manifests/
├── argocd/
│   ├── applications/
│   │   ├── app-of-apps.yaml.tpl          # Root application that manages all others
│   │   ├── trivy-operator.yaml.tpl       # Trivy security scanning operator
│   │   ├── kube-prometheus.yaml.tpl      # Prometheus monitoring stack
│   │   ├── postgres-operator.yaml.tpl    # CloudNativePG operator
│   │   ├── magebase-genfix.yaml.tpl      # Genfix client application
│   │   ├── magebase-site.yaml.tpl        # Site client application
│   │   └── kustomization.yaml.tpl        # Kustomization for all applications
│   └── README.md                         # Documentation
├── postgres/
│   ├── clusters/
│   │   ├── genfix-cluster.yaml.tpl       # Genfix PostgreSQL cluster (direct deployment)
│   │   ├── site-cluster.yaml.tpl         # Site PostgreSQL cluster (direct deployment)
│   │   ├── genfix-backup-secret.yaml.tpl # Genfix backup credentials
│   │   └── site-backup-secret.yaml.tpl   # Site backup credentials
│   └── kustomization.yaml.tpl            # Kustomization for postgres
├── bootstrap-app-of-apps.yaml.tpl        # Bootstrap application to initialize the pattern
└── kustomization.yaml.tpl                # Main kustomization including argocd and postgres
```

## Applications

### Core Infrastructure

- **app-of-apps**: The root application that manages all other applications
- **trivy-operator**: Security vulnerability scanning for containers and Kubernetes resources
- **kube-prometheus**: Complete monitoring stack with Prometheus, Grafana, and Alertmanager
- **postgres-operator**: CloudNativePG operator for PostgreSQL database management
- **postgres-clusters**: PostgreSQL database clusters for each client application

### Client Applications

- **magebase-genfix**: Genfix client application deployment
- **magebase-site**: Site client application deployment

## Bootstrap Process

1. Apply the bootstrap application:

   ```bash
   kubectl apply -f extra-manifests/bootstrap-app-of-apps.yaml.tpl
   ```

2. ArgoCD will automatically create and sync all applications defined in the `applications/` directory

3. Monitor the applications in the ArgoCD UI at <https://argocd-dev.magebase.dev>

## Adding New Client Applications

To add a new client application:

1. Create a new YAML file in `applications/` directory
2. Follow the pattern of existing client applications
3. Update the `kustomization.yaml` to include the new application
4. Commit and push changes
5. ArgoCD will automatically sync the new application

## Configuration

- All applications use automated sync with self-healing enabled
- Resources are configured with minimal CPU/memory requirements where applicable
- Namespaces are created automatically for each application
- Retry logic is configured for resilient deployments

## PostgreSQL Setup

The PostgreSQL setup uses CloudNativePG operator to provide managed PostgreSQL databases for each client application:

### Architecture

1. **postgres-operator**: Deploys the CloudNativePG operator to the `cnpg-system` namespace
2. **postgres-clusters**: Deploys PostgreSQL clusters for each client application
   - **genfix-db**: PostgreSQL cluster for the Genfix application
   - **site-db**: PostgreSQL cluster for the Site application

### Database Specifications

Each database cluster is configured with minimal resource requirements:

- **Instances**: 1 (single replica for development)
- **Storage**: 1Gi local storage
- **Memory**: 128Mi request, 256Mi limit
- **CPU**: 100m request, 200m limit
- **PostgreSQL Version**: 15.6

### Backup Configuration

Each cluster includes backup configuration with:

- **Retention**: 30 days
- **Storage**: S3-compatible object storage
- **Credentials**: Stored in dedicated secrets per cluster

### Adding New Databases

To add a database for a new client application:

1. Create a new cluster definition in `postgres/clusters/`
2. Create backup credentials secret
3. Update the `postgres/kustomization.yaml.tpl`
4. The postgres-clusters application will automatically deploy it
