apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # Base applications
  - app-of-apps.yaml.tpl
  - kube-prometheus.yaml.tpl
  - magebase-genfix.yaml.tpl
  - magebase-site.yaml.tpl
  - postgres-clusters.yaml.tpl
  - postgres-operator.yaml.tpl
  - trivy-operator.yaml.tpl

  # Environment-specific applications (only include current environment)
  - environments/genfix/${ENVIRONMENT}-fsn1.yaml.tpl
  - environments/site/${ENVIRONMENT}-fsn1.yaml.tpl

  # NOTE: Only the current environment's applications are included above
