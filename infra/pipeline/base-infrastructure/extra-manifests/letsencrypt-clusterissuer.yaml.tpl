apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-${ENVIRONMENT}
  labels:
    environment: ${ENVIRONMENT}
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: admin@magebase.dev
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-${ENVIRONMENT}
    # Enable the HTTP-01 challenge provider
    solvers:
    - http01:
        ingress:
          class: traefik
    # Enable DNS-01 challenge provider for wildcard certificates
    - dns01:
        cloudflare:
          email: admin@magebase.dev
          apiTokenSecretRef:
            name: cloudflare-api-token-secret
            key: api-token
      selector:
        dnsNames:
        - "*.magebase.dev"
        - "magebase.dev"
