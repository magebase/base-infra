apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-server
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
  - kind: Rule
    match: Host(`${ARGOCD_FQDN}`)
    services:
    - name: argocd-server
      port: 80
  tls:
    secretName: argocd-tls
