apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-https
  namespace: argocd
spec:
  entryPoints:
    - websecure
  routes:
  - kind: Rule
    match: Host(`${environment}-argocd.${domain_name}`)
    priority: 10
    services:
    - kind: Service
      name: argocd-server
      port: http
  - kind: Rule
    match: >-
      Host(`${environment}-argocd.${domain_name}`) &&
      Headers(`Content-Type`, `application/grpc`)
    priority: 11
    services:
    - kind: Service
      name: argocd-server
      port: http
      scheme: h2c
  tls:
    secretName: argocd-tls
