apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-tls
  namespace: argocd
  labels:
    environment: ${environment}
    app.kubernetes.io/name: argocd
    app.kubernetes.io/component: certificate
spec:
  secretName: argocd-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - argocd.${DOMAIN}
