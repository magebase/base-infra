apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: argocd
resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
  - letsencrypt-issuer.yaml
  - cloudflare-secret.yaml
  - argocd-certificate.yaml
  - postgresql-certificate.yaml
  - cert-debug.yaml
  - traefik-middleware.yaml
  - k3s-encryption.yaml
  - network-policies.yaml
  - pod-security.yaml
  - audit-policy.yaml

secretGenerator:
  - name: argocd-secret
    behavior: merge
    literals:
      - admin.password=${argocd_admin_password}
      - admin.passwordMtime=MjAyNS0wMS0wMVQwMDowMDowMFo=
    options:
      disableNameSuffixHash: true

patches:
  # Override namespace for Cloudflare secret to place it in cert-manager namespace
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: cert-manager
    target:
      kind: Secret
      name: cloudflare-api-token-secret
  # Patch for custom domain configuration
  - patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env
        value:
          - name: ARGOCD_SERVER_INSECURE
            value: "true"
          - name: ARGOCD_SERVER_ROOTPATH
            value: "/"
          - name: ARGOCD_SERVER_GRPC_WEB
            value: "true"
    target:
      kind: Deployment
      name: argocd-server
  # Patch for ingress configuration
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: argocd-server
        namespace: argocd
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-prod
          traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
          traefik.ingress.kubernetes.io/service.serversscheme: http
      spec:
        ingressClassName: traefik
        rules:
          - host: argocd.${DOMAIN}
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: argocd-server
                      port:
                        number: 80
        tls:
          - hosts:
              - argocd.${DOMAIN}
            secretName: argocd-tls
    target:
      kind: Ingress
      name: argocd-server
