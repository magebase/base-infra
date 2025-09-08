apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - aws-credentials-secrets.yaml
  - client-secret-stores.yaml
  - database-credentials.yaml

# Install External Secrets Operator using Helm
helmCharts:
  - name: external-secrets
    repo: https://charts.external-secrets.io
    version: 0.19.2
    releaseName: external-secrets
    namespace: external-secrets-system
    includeCRDs: true
    valuesInline:
      installCRDs: true
