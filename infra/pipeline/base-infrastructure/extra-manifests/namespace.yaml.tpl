apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: argocd
    app.kubernetes.io/instance: argocd-${ENVIRONMENT}
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
