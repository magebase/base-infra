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
  - traefik-middleware.yaml
  - argocd/github-pat-secret.yaml
  - argocd/applications/app-of-apps.yaml
  - argocd/applications/trivy-operator.yaml
  - argocd/applications/kube-prometheus.yaml
  - argocd/applications/postgres-operator.yaml
  - argocd/applications/magebase-genfix.yaml
  - argocd/applications/magebase-site.yaml
  - postgres/clusters/genfix-backup-secret.yaml
  - postgres/clusters/genfix-cluster.yaml
  - postgres/clusters/site-backup-secret.yaml
  - postgres/clusters/site-cluster.yaml

secretGenerator:
  - name: argocd-secret
    behavior: merge
    literals:
      - admin.password=${ARGOCD_ADMIN_PASSWORD}
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
  # Configure ArgoCD server to serve HTTP instead of HTTPS
  - patch: |-
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: argocd-cmd-params-cm
        namespace: argocd
      data:
        server.insecure: "true"
    target:
      kind: ConfigMap
      name: argocd-cmd-params-cm
  # Exclude ArgoCD network policies from namespace transformation to avoid conflicts
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-application-controller-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-applicationset-controller-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-dex-server-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-notifications-controller-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-redis-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-repo-server-network-policy
  - patch: |-
      - op: replace
        path: /metadata/namespace
        value: default
    target:
      kind: NetworkPolicy
      name: argocd-server-network-policy
