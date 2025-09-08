# StackGres Database Connectivity Setup

This document explains how to set up database connectivity between the base-infra repository (containing StackGres clusters) and client repositories (containing applications that need database access).

## Overview

The setup uses:

- **StackGres Operator**: Automatically generates database users and passwords
- **Kubernetes Secrets**: Store database connection credentials
- **ArgoCD**: Manages deployment ordering to ensure databases are ready before applications
- **External Secrets Operator**: Syncs secrets between namespaces

## Base-Infra Repository Setup

### 1. StackGres Cluster Configuration

The base-infra repository contains StackGres cluster definitions with automatic credential generation:

```yaml
# Example from genfix/dev-cluster.yaml.tpl
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  name: genfix-dev-cluster
spec:
  # ... cluster configuration ...
  managedUsers:
  - username: genfix_app
    database: genfix
    password:
      type: 'random'
      length: 16
      seed: 'genfix-dev-seed'
```

### 2. Generated Secrets

StackGres automatically creates secrets containing:

- Database connection URLs
- User credentials
- Individual connection components (host, port, database, user, password)

### 3. ArgoCD Applications

The setup includes ArgoCD applications for proper deployment ordering:

```yaml
# Base infrastructure (databases)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: base-infra-citus
spec:
  source:
    repoURL: https://github.com/magebase/base-infra
    path: infra/pipeline/base-infrastructure/extra-manifests/citus

# Client application (depends on database)
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: client-app-genfix
spec:
  source:
    repoURL: https://github.com/magebase/client-genfix
    path: k8s
```

## Client Repository Setup

### 1. Knative Service Configuration

Client applications use Knative services that reference the database secrets:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: genfix-app
  namespace: client1-ns
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        # Database connection from StackGres generated secret
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: genfix-dev-cluster-db-url
              key: DATABASE_URL
        - name: DB_HOST
          valueFrom:
            secretKeyRef:
              name: genfix-dev-cluster-db-url
              key: DB_HOST
        # ... other database environment variables
```

### 2. External Secrets for Cross-Namespace Access

Use External Secrets Operator to sync database secrets to client namespaces:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: genfix-db-credentials
  namespace: client1-ns
spec:
  secretStoreRef:
    name: internal-secret-store
    kind: SecretStore
  target:
    name: genfix-dev-cluster-db-url
  data:
  - secretKey: DATABASE_URL
    remoteRef:
      key: genfix-dev-cluster-db-url
      property: DATABASE_URL
```

## Deployment Order

1. **Deploy Base-Infra**: Creates StackGres clusters and generates secrets
2. **Wait for Database Readiness**: Ensure clusters are fully operational
3. **Deploy Client Apps**: Applications can now access database credentials

## Available Secrets

### Genfix Application

- `genfix-dev-cluster-db-url`: Complete database connection information
- `genfix-dev-app-credentials`: Application-specific user credentials

### Site Application

- `site-dev-cluster-db-url`: Complete database connection information
- `site-dev-app-credentials`: Application-specific user credentials

## Environment Variables

Applications can access these environment variables:

- `DATABASE_URL`: Full connection string
- `DB_HOST`: Database host
- `DB_PORT`: Database port
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password

## Scaling Configuration

All clusters are configured with:

- **Horizontal autoscaling**: Scale to 0 when no connections
- **Connection-based scaling**: 80% connection usage threshold
- **Automatic credential management**: StackGres handles user creation

## Security Considerations

- Database credentials are automatically generated and rotated
- Secrets are namespace-scoped for security
- External Secrets Operator enables secure cross-namespace access
- ArgoCD ensures proper deployment dependencies
