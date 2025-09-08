apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - aws-credentials-secrets.yaml
  - client-secret-stores.yaml
  - database-credentials.yaml

# ESO will be installed manually via Helm in extra_kustomize_deployment_commands
# to avoid requiring --enable-helm flag in kustomize
