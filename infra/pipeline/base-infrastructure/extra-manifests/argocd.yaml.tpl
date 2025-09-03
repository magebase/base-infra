# ArgoCD will be installed separately
# This file is kept for future ArgoCD Application definitions
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-placeholder
  namespace: argocd
data:
  note: "ArgoCD installation will be handled separately"
