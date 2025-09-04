apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-tls
  namespace: argocd
  labels:
    environment: ${environment}
    app.kubernetes.io/name: argocd
    app.kubernetes.io/component: certificate
  annotations:
    cert-manager.io/revision-history-limit: "3"
    # Force renewal timestamp
    force-renewal: "2025-09-04T12:15:00Z"
spec:
  secretName: argocd-tls
  issuerRef:
    name: letsencrypt-staging
    kind: ClusterIssuer
  dnsNames:
    - argocd.${DOMAIN}
  # Add duration and renewal before for debugging
  duration: 2160h # 90 days
  renewBefore: 360h # 15 days
