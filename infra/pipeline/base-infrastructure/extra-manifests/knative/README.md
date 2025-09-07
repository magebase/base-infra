# Knative Installation with Kustomize

This directory contains Kustomize templates for installing Knative Serving v1.18.1 with Kourier networking and HPA autoscaling.

## Components

- **serving-crds.yaml.tpl**: Custom Resource Definitions for Knative Serving
- **serving-core.yaml.tpl**: Core Knative Serving components (controller, activator, autoscaler, webhook)
- **kourier.yaml.tpl**: Kourier networking layer for ingress
- **serving-default-domain.yaml.tpl**: Default domain configuration
- **serving-hpa.yaml.tpl**: HPA autoscaling extension
- **config-network-patch.yaml.tpl**: Network configuration patch for Kourier integration
- **kustomization.yaml**: Kustomize configuration file

## Installation

1. **Prerequisites**:
   - Kubernetes cluster (v1.25+)
   - kubectl configured to access your cluster
   - Kustomize installed (or kubectl with kustomize support)

2. **Customize Configuration**:
   - Edit `serving-default-domain.yaml.tpl` to configure your domain
   - Update `config-network-patch.yaml.tpl` with your ingress class and domain settings
   - Review image tags in `kustomization.yaml` if needed

3. **Install Knative**:

   ```bash
   # Navigate to the knative directory
   cd infra/pipeline/base-infrastructure/extra-manifests/knative/

   # Apply the manifests
   kubectl apply -k .

   # Wait for all pods to be ready
   kubectl wait --for=condition=Ready pod --all -n knative-serving
   kubectl wait --for=condition=Ready pod --all -n kourier-system
   ```

4. **Verify Installation**:

   ```bash
   # Check Knative Serving components
   kubectl get pods -n knative-serving

   # Check Kourier components
   kubectl get pods -n kourier-system

   # Check CRDs
   kubectl get crd | grep knative
   ```

## Configuration

### Domain Configuration

Edit `serving-default-domain.yaml.tpl` to configure your domain:

- For production: Replace `example.com` with your actual domain
- For development: Use magic DNS like `sslip.io` or `nip.io`

### Network Configuration

The `config-network-patch.yaml.tpl` configures:

- Kourier as the ingress class
- Domain template: `{{.Name}}.{{.Namespace}}.{{.Domain}}`
- HTTP protocol (can be changed to HTTPS with TLS)

### Autoscaling

The HPA extension provides:

- CPU and memory-based autoscaling
- Configurable min/max replicas
- Stabilization windows for smooth scaling

## Usage

After installation, you can create Knative services:

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: hello-world
  namespace: default
spec:
  template:
    spec:
      containers:
      - image: gcr.io/knative-samples/helloworld-go
        env:
        - name: TARGET
          value: "Go Sample v1"
```

Apply with: `kubectl apply -f service.yaml`

## Troubleshooting

1. **Check pod status**:

   ```bash
   kubectl get pods -n knative-serving
   kubectl get pods -n kourier-system
   ```

2. **Check logs**:

   ```bash
   kubectl logs -n knative-serving deployment/controller
   kubectl logs -n kourier-system deployment/3scale-kourier-gateway
   ```

3. **Verify CRDs**:

   ```bash
   kubectl get crd | grep knative
   ```

4. **Check network configuration**:

   ```bash
   kubectl get configmap config-network -n knative-serving -o yaml
   ```

## Uninstallation

To remove Knative:

```bash
kubectl delete -k .
```

This will remove all Knative components and CRDs.
