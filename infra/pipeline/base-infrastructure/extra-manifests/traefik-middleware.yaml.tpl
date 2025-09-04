# Traefik middleware for HTTPS redirects and security headers
# This ensures proper SSL handling and security

---
# Middleware for HTTPS redirect
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: redirect-https
  namespace: default
  labels:
    app.kubernetes.io/name: traefik-middleware
spec:
  redirectScheme:
    scheme: https
    permanent: true

---
# Security headers middleware
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: security-headers
  namespace: default
  labels:
    app.kubernetes.io/name: traefik-middleware
spec:
  headers:
    customRequestHeaders:
      X-Forwarded-Proto: "https"
    customResponseHeaders:
      X-Robots-Tag: "noindex,nofollow,nosnippet,noarchive,notranslate,noimageindex"
      server: ""
    sslRedirect: true
    sslTemporaryRedirect: true
    sslHost: ""
    sslForceHost: false
    stsSeconds: 31536000
    stsIncludeSubdomains: true
    stsPreload: true
    forceSTSHeader: true
    frameDeny: true
    contentTypeNosniff: true
    browserXssFilter: true
    referrerPolicy: "strict-origin-when-cross-origin"
    permissionsPolicy: "camera=(), microphone=(), geolocation=()"
    customFrameOptionsValue: "SAMEORIGIN"

---
# ArgoCD specific middleware chain
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: argocd-middleware
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-middleware
spec:
  chain:
    middlewares:
    - name: default-redirect-https@kubernetescrd
    - name: default-security-headers@kubernetescrd

---
# ArgoCD server configuration middleware (handle gRPC and insecure mode)
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: argocd-server
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-middleware
spec:
  headers:
    customRequestHeaders:
      X-Forwarded-Proto: "https"
      X-Forwarded-For: ""
    customResponseHeaders:
      X-Frame-Options: "SAMEORIGIN"
      X-Content-Type-Options: "nosniff"
    sslRedirect: true
