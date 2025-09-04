apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: argocd
resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.1/manifests/install.yaml
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
