apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

metadata:
  name: magebase-base-infrastructure

# Common labels applied to all resources
commonLabels:
  app.kubernetes.io/part-of: magebase
  component: base-infrastructure

# Namespace for base infrastructure components
namespace: argocd

# Resources to deploy - ONLY ArgoCD for base infrastructure
resources:
  - argocd.yaml

# ConfigMap for base infrastructure configuration
configMapGenerator:
  - name: base-infrastructure-config
    literals:
      - ENVIRONMENT=${environment}
      - COMPONENT=base-infrastructure
      - DOMAIN=${domain}
      - ARGOCD_ADMIN_PASSWORD=${argocd_admin_password}
