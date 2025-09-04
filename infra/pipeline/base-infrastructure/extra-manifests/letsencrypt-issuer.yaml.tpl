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
      # HTTP01 solver for basic domains
      - http01:
          ingress:
            class: traefik
        selector:
          dnsNames:
            - "magebase.dev"
            - "*.magebase.dev"
      # DNS01 solver for subdomains not covered by Cloudflare free SSL
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsNames:
            - "argocd.dev.magebase.dev"
            - "*.dev.magebase.dev"
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
      # HTTP01 solver for basic domains
      - http01:
          ingress:
            class: traefik
        selector:
          dnsNames:
            - "magebase.dev"
            - "*.magebase.dev"
      # DNS01 solver for subdomains not covered by Cloudflare free SSL
      - dns01:
          cloudflare:
            apiTokenSecretRef:
              name: cloudflare-api-token-secret
              key: api-token
        selector:
          dnsNames:
            - "argocd.dev.magebase.dev"
            - "*.dev.magebase.dev"
