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

#### Prometheus Scaled Object (`prometheus-scaledobject.yaml.tpl`)

- Scales based on custom Prometheus metrics
- Supports complex queries and authentication

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

## Integration with Knative

KEDA works seamlessly with Knative Serving for advanced serverless capabilities:

- Use KEDA for event-driven scaling
- Knative handles request routing and cold starts
- Combine both for optimal resource utilization

## Security Considerations

- Use RBAC to restrict access to ScaledObject resources
- Store authentication secrets securely
- Monitor for unusual scaling patterns
- Implement resource limits and quotas
