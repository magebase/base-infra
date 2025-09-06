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

  # Genfix applications (single region - fsn1)
  - environments/genfix/dev-fsn1.yaml.tpl
  # - environments/genfix/qa-fsn1.yaml.tpl  # Commented out - QA deployments disabled
  # - environments/genfix/uat-fsn1.yaml.tpl # Commented out - UAT deployments disabled
  - environments/genfix/prod-fsn1.yaml.tpl

  # Site applications (single region - fsn1)
  - environments/site/dev-fsn1.yaml.tpl
  # - environments/site/qa-fsn1.yaml.tpl  # Commented out - QA deployments disabled
  # - environments/site/uat-fsn1.yaml.tpl # Commented out - UAT deployments disabled
  - environments/site/prod-fsn1.yaml.tpl

  # NOTE: Old region-specific applications removed - using segregated environment structure above
