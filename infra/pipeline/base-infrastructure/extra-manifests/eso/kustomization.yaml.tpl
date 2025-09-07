apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - https://github.com/external-secrets/external-secrets/releases/download/stable/external-secrets.yaml
  - namespace.yaml
  - service-account.yaml
  - aws-secret-store.yaml
  - client-secret-stores.yaml

namespace: external-secrets-system
