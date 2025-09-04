apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-api-token-secret
  namespace: argocd
type: Opaque
data:
  # This will be populated by the deployment pipeline
  api-token: ""
