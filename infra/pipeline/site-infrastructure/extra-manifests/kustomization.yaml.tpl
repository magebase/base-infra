apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: magebase-extra-components

# Common labels applied to all resources
commonLabels:
  app.kubernetes.io/part-of: magebase
  environment: ${environment}

# Namespace for monitoring components
namespace: monitoring

# Resources to deploy
resources:
  - kube-prometheus-stack.yaml
  - argocd.yaml
  - cnpg.yaml
  - kubernetes-dashboard.yaml
  - magebase-app-dev.yaml
  - magebase-app-prod.yaml

# Patches for environment-specific configuration
patchesStrategicMerge:
  - patches/${environment}.yaml

# ConfigMap for environment-specific values
configMapGenerator:
  - name: magebase-config
    literals:
      - ENVIRONMENT=${environment}
      - DOMAIN=${domain}

# Secret for sensitive configuration (if needed)
# secretGenerator:
#   - name: magebase-secrets
#     literals:
#       - API_KEY=your-api-key-here
