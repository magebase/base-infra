apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: argocd-https
  namespace: argocd
  annotations:
    # This annotation tells Traefik to expect unencrypted HTTP from the load balancer
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
    # This annotation tells Traefik to use the http scheme to communicate with the backend service
    traefik.ingress.kubernetes.io/service.serversscheme: "http"
spec:
  entryPoints:
    - websecure
  routes:
  - kind: Rule
    match: Host(`${domain}`)
    priority: 10
    services:
    - kind: Service
      name: argocd-server
      port: http
  - kind: Rule
    match: >-
      Host(`${domain}`) &&
      Headers(`Content-Type`, `application/grpc`)
    priority: 11
    services:
    - kind: Service
      name: argocd-server
      port: http
      scheme: h2c
