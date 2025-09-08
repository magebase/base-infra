apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - namespace-stackgres.yaml
  - database-r2-credentials.yaml
  # NOTE: StackGres operator resources are deployed via Helm to avoid conflicts
  # The operator, RBAC, certificates, and CRDs are managed by Helm installation
  # - operator/rbac.yaml
  # - operator/deployment.yaml
  # - operator/restapi.yaml
  # - operator/certificates.yaml
  # NOTE: StackGres custom resources are deployed via ArgoCD after operators are installed
  # to avoid CRD dependency issues during initial deployment
  # - environments/genfix/${ENVIRONMENT}.yaml
  # - environments/site/${ENVIRONMENT}.yaml

# Removed namespace transformation since we explicitly create namespaces
# namespace: database
