# KEDA (Kubernetes Event-driven Autoscaling)

This directory contains KEDA configurations for event-driven autoscaling in the Kubernetes cluster.

## Overview

KEDA (Kubernetes Event-driven Autoscaling) allows you to scale your Kubernetes workloads based on external events and metrics from various sources.

## Components

### 1. KEDA Operator (`keda.yaml.tpl`)

- Deploys the KEDA operator via Helm chart
- Includes Prometheus metrics and webhooks
- Configured with security best practices

### 2. Scaled Objects (`scaledobjects/`)

Sample scaled objects for different scaling scenarios:

#### HTTP Scaled Object (`http-scaledobject.yaml.tpl`)

- Scales based on HTTP request metrics from Prometheus
- Useful for web applications with variable traffic

#### CPU/Memory Scaled Object (`cpu-scaledobject.yaml.tpl`)

- Scales based on CPU and memory utilization
- Traditional resource-based autoscaling

#### YugabyteDB Scaled Object (`yugabyte-scaledobject.yaml.tpl`)

- Scales YugabyteDB tserver pods based on database connections, CPU, and memory usage
- Supports scaling to zero when database load is low
- Includes multiple triggers for comprehensive autoscaling
- Configured for both genfix-cluster and site-cluster with CPU-based scaling

#### Environment-Specific Scaled Objects

- **Dev Scaled Object** (`dev-scaledobject.yaml.tpl`): Minimal scaling for development
- **QA Scaled Object** (`qa-scaledobject.yaml.tpl`): Standard scaling for QA environment
- **UAT Scaled Object** (`uat-scaledobject.yaml.tpl`): Standard scaling for UAT environment
- **Prod Scaled Object** (`prod-scaledobject.yaml.tpl`): Conservative scaling for production (min 1 replica)

## Usage

### Deploying KEDA

1. The KEDA operator is deployed via ArgoCD application
2. Scaled objects are deployed via the `keda-scaledobjects` ArgoCD application

### Creating Custom Scaled Objects

1. Create a new YAML file in the `scaledobjects/` directory
2. Follow the KEDA ScaledObject CRD specification
3. Add the new file to `kustomization.yaml.tpl`
4. Commit and push changes

### Supported Triggers

- **HTTP**: Scale based on HTTP request metrics
- **CPU/Memory**: Scale based on resource utilization
- **Prometheus**: Scale based on Prometheus metrics
- **Kafka**: Scale based on Kafka topic lag
- **RabbitMQ**: Scale based on queue length
- **AWS SQS**: Scale based on queue length
- **Azure Service Bus**: Scale based on queue length
- **GCP Pub/Sub**: Scale based on subscription backlog
- And many more...

## Configuration

### Authentication

For triggers that require authentication (like Prometheus), create secrets with the required credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keda-auth-secret
  namespace: default
type: Opaque
data:
  # Base64 encoded credentials
  username: <base64-encoded>
  password: <base64-encoded>
```

### Scaling Policies

Configure scaling behavior:

- `minReplicaCount`: Minimum number of replicas
- `maxReplicaCount`: Maximum number of replicas
- `pollingInterval`: How often to check metrics (seconds)
- `cooldownPeriod`: Cooldown period after scaling (seconds)

## Monitoring

KEDA exposes metrics that can be scraped by Prometheus:

- `keda_scaler_metrics_value`: Current metric value
- `keda_scaler_desired_replicas`: Desired number of replicas
- `keda_scaler_active`: Whether the scaler is active

## Troubleshooting

### Common Issues

1. **ScaledObject not scaling**: Check trigger configuration and authentication
2. **Metrics not available**: Verify Prometheus configuration and queries
3. **Authentication failures**: Check secret configuration and permissions

### Debugging

1. Check KEDA operator logs:

   ```bash
   kubectl logs -n keda-system deployment/keda-operator
   ```

2. Check ScaledObject status:

   ```bash
   kubectl describe scaledobject <name> -n <namespace>
   ```

3. Verify metrics:

   ```bash
   kubectl get --raw "/apis/external.metrics.k8s.io/v1beta1/namespaces/default/scaledobjects/http-scaledobject"
   ```

## Scaling to Zero

KEDA supports scaling workloads to zero replicas when there is no activity, which can significantly reduce costs for development and staging environments.

### YugabyteDB Integration

The YugabyteDB scaled objects are configured to:

- Scale based on active database connections
- Scale based on CPU and memory utilization
- Allow scaling to zero during periods of low activity
- Maintain minimum performance during scale-up events

### CPU-Based Scaling for Genfix and Site Clusters

Both genfix and site clusters are configured with dedicated CPU-based scaled objects:

```yaml
triggers:
- type: cpu
  metadata:
    type: Utilization
    value: "70"          # Scale up at 70% CPU
    activationThreshold: "30"  # Scale down at 30% CPU
```

This ensures optimal resource utilization while maintaining performance for application workloads.

### Configuration for Scale to Zero

```yaml
minReplicaCount: 0  # Allow scaling to zero
maxReplicaCount: 5  # Maximum replicas during high load
cooldownPeriod: 300  # 5 minutes cooldown after scaling
```

## Integration with Knative

KEDA works seamlessly with Knative Serving for advanced serverless capabilities:

- Use KEDA for event-driven scaling
- Knative handles request routing and cold starts
- Combine both for optimal resource utilization
- YugabyteDB provides the data layer with automatic scaling

## Security Considerations

- Use RBAC to restrict access to ScaledObject resources
- Store authentication secrets securely
- Monitor for unusual scaling patterns
- Implement resource limits and quotas
