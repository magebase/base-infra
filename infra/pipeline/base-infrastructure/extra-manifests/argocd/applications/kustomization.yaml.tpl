apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - app-of-apps.yaml.tpl
  - trivy-operator.yaml.tpl
  - kube-prometheus.yaml.tpl
  - postgres-operator.yaml.tpl
  - magebase-genfix.yaml.tpl
  - magebase-site.yaml.tpl

# Common labels for all applications
commonLabels:
  app.kubernetes.io/managed-by: argocd
  app.kubernetes.io/part-of: app-of-apps
