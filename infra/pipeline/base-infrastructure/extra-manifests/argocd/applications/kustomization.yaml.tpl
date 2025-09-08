apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # Base applications
  - app-of-apps.yaml
  - kube-prometheus.yaml
  - magebase-genfix.yaml
  - magebase-site.yaml
  - trivy-operator.yaml

  # Environment-specific applications (only include current environment)
  - environments/genfix/${ENVIRONMENT}-fsn1.yaml
  - environments/site/${ENVIRONMENT}-fsn1.yaml

  # NOTE: Only the current environment's applications are included above
