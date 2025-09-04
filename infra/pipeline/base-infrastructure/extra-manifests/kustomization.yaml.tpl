apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: argocd
resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
  - letsencrypt-issuer.yaml
  - cloudflare-secret.yaml
  - postgresql-certificate.yaml
  - cert-debug.yaml
  - k3s-encryption.yaml
  - network-policies.yaml
  - pod-security.yaml
  - audit-policy.yaml
  - argocd-ingress.yaml

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
  # Patch to mount TLS secret and enable TLS in argocd-server
  - patch: |-
      - op: add
        path: /spec/template/spec/volumes
        value:
          - name: argocd-tls
            secret:
              secretName: argocd-tls
      - op: add
        path: /spec/template/spec/containers/0/volumeMounts
        value:
          - name: argocd-tls
            mountPath: /app/config/tls
            readOnly: true
      - op: add
        path: /spec/template/spec/containers/0/args
        value:
          - "--tls-cert-file=/app/config/tls/tls.crt"
          - "--tls-private-key-file=/app/config/tls/tls.key"
      - op: replace
        path: /spec/template/spec/containers/0/env
        value:
          - name: ARGOCD_SERVER_INSECURE
            value: "false"
          - name: ARGOCD_SERVER_ROOTPATH
            value: "/"
          - name: ARGOCD_SERVER_GRPC_WEB
            value: "true"
    target:
      kind: Deployment
      name: argocd-server
