apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@magebase.dev
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      # DNS01 solver for Cloudflare-managed domains
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsZones:
            - "magebase.dev"
            - "dev.magebase.dev"
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: admin@magebase.dev
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
      # DNS01 solver for Cloudflare-managed domains (recommended for ArgoCD and other subdomains)
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsNames:
            - "*.magebase.dev"
            - "*.dev.magebase.dev"
            - "argocd.dev.magebase.dev"
      # HTTP01 solver for public domains (fallback)
      - http01:
          ingress:
            class: traefik
        selector:
          dnsNames:
            - "magebase.dev"
