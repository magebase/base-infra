apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # Base applications
  - kube-prometheus.yaml
  - trivy-operator.yaml

  # NOTE: Environment-specific applications are deployed via ArgoCD after initial setup
  # to avoid file not found errors during initial kustomize deployment
  # - environments/genfix/${ENVIRONMENT}-fsn1.yaml
  # - environments/site/${ENVIRONMENT}-fsn1.yaml

  # NOTE: Only the current environment's applications are included above
