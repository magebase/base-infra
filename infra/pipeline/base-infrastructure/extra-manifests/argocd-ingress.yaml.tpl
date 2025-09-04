apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # Use Traefik TLS passthrough so Traefik forwards TCP/TLS to backend.
    traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
    traefik.ingress.kubernetes.io/router.tls: "true"
    traefik.ingress.kubernetes.io/router.tls.passthrough: "true"
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
              number: 443
  tls:
    - hosts:
        - dev-argocd.magebase.dev
