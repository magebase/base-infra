apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    environment: ${environment}
    app.kubernetes.io/name: argocd
    app.kubernetes.io/instance: argocd-${environment}
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
