# YugabyteDB Distributed Database

This directory contains YugabyteDB configurations for distributed SQL database deployment across all environments.

## Overview

YugabyteDB is a distributed SQL database that is PostgreSQL-compatible and provides horizontal scalability, fault tolerance, and global data distribution.

## Architecture

### Single Master Node Configuration

All environments are configured with a single master node for simplicity and resource efficiency:

- **Development**: Minimal resources (0.5-1 CPU, 1-2Gi memory)
- **QA/UAT**: Standard resources (1-2 CPU, 2-4Gi memory)
- **Production**: High resources (4-8 CPU, 8-16Gi memory)
- **Genfix/Site**: Optimized resources (2-4 CPU, 4-8Gi memory)

### Cluster Configurations

#### Environment-Specific Clusters

- `dev-cluster.yaml.tpl`: Development environment with minimal resources
- `qa-cluster.yaml.tpl`: QA environment with standard resources
- `uat-cluster.yaml.tpl`: UAT environment with standard resources
- `prod-cluster.yaml.tpl`: Production environment with high resources
- `genfix-cluster.yaml.tpl`: Genfix application cluster
- `site-cluster.yaml.tpl`: Site application cluster

## Features

### Cloudflare R2 Backup Storage

All clusters are configured to use Cloudflare R2 for backup storage:

- Cost-effective object storage
- Global distribution
- S3-compatible API
- Automatic backup scheduling

### TLS Security

- Certificate Manager integration for automatic TLS certificate management
- Secure communication between cluster nodes
- Environment-specific DNS names

### Monitoring Integration

- Prometheus metrics collection
- 30-second scrape intervals
- Integration with existing monitoring stack

## Configuration

### Secrets Management

Three types of secrets are required:

1. **Database Credentials** (`yugabyte-db-credentials`)
   - Username: admin (base64 encoded)
   - Password: Generated during deployment

2. **TLS Certificates** (`yugabyte-tls-certs`)
   - CA certificate
   - Server certificate
   - Private key

3. **R2 Credentials** (`yugabyte-r2-credentials`)
   - Access key (base64 encoded)
   - Secret key (base64 encoded)

### Storage Configuration

- **Master nodes**: Persistent storage for metadata
- **TServer nodes**: Persistent storage for data
- **Storage class**: local-path (can be customized per environment)

### Resource Allocation

Resources are allocated based on environment requirements:

| Environment | Master CPU | Master Memory | TServer CPU | TServer Memory | Storage |
|-------------|------------|---------------|-------------|----------------|---------|
| dev         | 0.5-1     | 1-2Gi        | 0.5-1      | 1-2Gi         | 50-100Gi |
| qa/uat      | 1-2       | 2-4Gi        | 1-2        | 2-4Gi         | 100-200Gi |
| prod        | 4-8       | 8-16Gi       | 4-8        | 8-16Gi        | 500Gi-1Ti |
| genfix/site | 2-4       | 4-8Gi        | 2-4        | 4-8Gi         | 100-200Gi |

## Deployment

### Prerequisites

1. Kubernetes cluster with sufficient resources
2. cert-manager installed for TLS certificates
3. Cloudflare R2 account and credentials
4. Prometheus monitoring stack

### Setup Script

Use the provided setup script to configure secrets:

```bash
# For genfix cluster
./scripts/setup-yugabyte-secrets.sh genfix-cluster

# For other clusters
./scripts/setup-yugabyte-secrets.sh <cluster-name>
```

The script will:

- Generate secure database passwords
- Create self-signed TLS certificates (for development)
- Prompt for Cloudflare R2 credentials
- Create all required Kubernetes secrets

### Manual Secret Creation

If you prefer manual secret creation:

```bash
# Database credentials
kubectl create secret generic yugabyte-db-credentials \
  --namespace=yb \
  --from-literal=username=admin \
  --from-literal=password=<secure-password>

# TLS certificates
kubectl create secret generic yugabyte-tls-certs \
  --namespace=yb \
  --from-file=ca.crt=ca.pem \
  --from-file=tls.crt=server.pem \
  --from-file=tls.key=server-key.pem

# R2 credentials
kubectl create secret generic yugabyte-r2-credentials \
  --namespace=yb \
  --from-literal=accessKey=<base64-r2-access-key> \
  --from-literal=secretKey=<base64-r2-secret-key>
```

## Backup and Recovery

### Automated Backups

- **Schedule**: Environment-specific (daily at different times)
- **Retention**: 7-90 days based on environment
- **Storage**: Cloudflare R2 buckets
- **Encryption**: TLS encryption in transit

### Backup Configuration

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: "30d"
  storage:
    type: s3
    bucket: <env>-yugabyte-backups
    region: auto
    endpoint: https://<account-id>.r2.cloudflarestorage.com
    credentialsSecret: yugabyte-r2-credentials
```

## Monitoring and Observability

### Metrics

YugabyteDB exposes comprehensive metrics:

- Node health and status
- Query performance
- Replication status
- Resource utilization
- Backup status

### Integration

- Prometheus for metrics collection
- Grafana for visualization
- AlertManager for notifications

## Scaling

### KEDA Integration

YugabyteDB clusters integrate with KEDA for intelligent scaling:

- **Connection-based scaling**: Scale based on active connections
- **Resource-based scaling**: Scale based on CPU/memory usage
- **Scale to zero**: Reduce costs during low-usage periods

### HPA Configuration

```yaml
minReplicaCount: 0  # Allow scaling to zero
maxReplicaCount: 5  # Maximum replicas
cooldownPeriod: 300  # 5-minute cooldown
```

## Troubleshooting

### Common Issues

1. **Pod fails to start**: Check resource allocation and storage
2. **Backup failures**: Verify R2 credentials and connectivity
3. **TLS certificate issues**: Check cert-manager configuration
4. **Scaling problems**: Review KEDA scaled object configuration

### Logs

```bash
# Master logs
kubectl logs -n yb -l app.kubernetes.io/name=yugabyte,app.kubernetes.io/component=master

# TServer logs
kubectl logs -n yb -l app.kubernetes.io/name=yugabyte,app.kubernetes.io/component=tserver
```

### Health Checks

```bash
# Check cluster status
kubectl get ybcluster -n yb

# Check pod status
kubectl get pods -n yb

# Check services
kubectl get svc -n yb
```

## Security Considerations

- Use strong passwords for database access
- Enable TLS encryption for all connections
- Regularly rotate R2 credentials
- Implement network policies for pod communication
- Use RBAC for access control

## Performance Tuning

### Memory Configuration

- Allocate sufficient memory for working set
- Monitor memory usage patterns
- Adjust based on query patterns

### Storage Optimization

- Use appropriate storage classes
- Monitor IOPS and throughput
- Consider SSD storage for better performance

### Network Configuration

- Ensure low-latency network between nodes
- Configure appropriate timeouts
- Monitor network saturation
