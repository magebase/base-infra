apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # Let Hetzner LB terminate TLS and forward HTTP to Traefik
    traefik.ingress.kubernetes.io/router.entrypoints: "web"
    traefik.ingress.kubernetes.io/service.serversscheme: "http"
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - {argocd_fqdn}
    secretName: argocd-tls
  rules:
  - host: {argocd_fqdn}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80  # Corrected from 8080 to match service port
