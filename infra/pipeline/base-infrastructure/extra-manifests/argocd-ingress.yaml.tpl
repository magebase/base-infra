apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    # SSL terminates at Hetzner LB, so use websecure entrypoint
    traefik.ingress.kubernetes.io/router.entrypoints: "websecure"
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
              number: 80
