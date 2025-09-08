apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - database-r2-credentials.yaml
  - operator/rbac.yaml
  - operator/deployment.yaml
  - operator/restapi.yaml
  - operator/certificates.yaml
  - genfix/${ENVIRONMENT}-cluster.yaml
  - site/${ENVIRONMENT}-cluster.yaml

namespace: database
