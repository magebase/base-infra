apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - https://github.com/external-secrets/external-secrets/releases/download/v0.19.2/external-secrets.yaml
  - namespace.yaml
  - aws-credentials-secrets.yaml
  - client-secret-stores.yaml
