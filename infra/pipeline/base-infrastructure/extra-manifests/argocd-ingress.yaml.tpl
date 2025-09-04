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
    match: Host(`{argocd_fqdn}`)
    services:
    - name: argocd-server
      port: 80
    middlewares:
    - name: argocd-middleware
  tls:
    secretName: argocd-tls
