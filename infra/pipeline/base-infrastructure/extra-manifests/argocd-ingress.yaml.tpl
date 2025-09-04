apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # TCP passthrough from Hetzner LB to Traefik for end-to-end TLS
    traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
    traefik.ingress.kubernetes.io/service.serversscheme: "https"
    # Enable TLS passthrough for end-to-end encryption
    traefik.ingress.kubernetes.io/router.tls.passthrough: "true"
    # Redirect HTTP to HTTPS
    traefik.ingress.kubernetes.io/redirect-scheme: https
    traefik.ingress.kubernetes.io/redirect-permanent: "true"
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - dev-argocd.magebase.dev
    secretName: argocd-tls
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
              number: 443  # Changed from 80 to 443 for TLS passthrough
