apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-tls
  namespace: argocd
spec:
  secretName: argocd-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - argocd.dev.magebase.dev
    - argocd.qa.magebase.dev
    - argocd.uat.magebase.dev
    - argocd.prod.magebase.dev
