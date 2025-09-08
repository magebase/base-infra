apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - database-r2-credentials.yaml
  - operator/rbac.yaml
  - operator/deployment.yaml
  - operator/restapi.yaml
  - operator/certificates.yaml
  - environments/genfix/${ENVIRONMENT}-fsn1.yaml
  - environments/site/${ENVIRONMENT}-fsn1.yaml

namespace: database
