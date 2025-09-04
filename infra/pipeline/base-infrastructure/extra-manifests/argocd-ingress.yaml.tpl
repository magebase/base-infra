apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # TLS termination at Hetzner LB, HTTP traffic to Traefik
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
    traefik.ingress.kubernetes.io/service.serversscheme: "http"
spec:
  ingressClassName: traefik
  rules:
  - host: dev-argocd.magebase.dev
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80  # ArgoCD expects HTTP traffic
