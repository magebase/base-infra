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
  # Rename all conflicting network policies to avoid conflicts
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: default-deny-all
        namespace: default
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: default-deny-all
          internal.config.kubernetes.io/previousNamespaces: default
      newName: "default-deny-all-renamed"
    target:
      kind: NetworkPolicy
      name: default-deny-all
      namespace: default
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: allow-dns
        namespace: default
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: allow-dns
          internal.config.kubernetes.io/previousNamespaces: default
      newName: "allow-dns-renamed"
    target:
      kind: NetworkPolicy
      name: allow-dns
      namespace: default
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: allow-api-server
        namespace: default
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: allow-api-server
          internal.config.kubernetes.io/previousNamespaces: default
      newName: "allow-api-server-renamed"
    target:
      kind: NetworkPolicy
      name: allow-api-server
      namespace: default
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-allow
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-allow
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-allow-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-allow
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-server-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-server-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-server-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-server-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-redis-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-redis-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-redis-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-redis-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-repo-server-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-repo-server-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-repo-server-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-repo-server-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-application-controller-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-application-controller-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-application-controller-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-application-controller-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-applicationset-controller-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-applicationset-controller-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-applicationset-controller-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-applicationset-controller-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-dex-server-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-dex-server-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-dex-server-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-dex-server-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: argocd-notifications-controller-network-policy
        namespace: argocd
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: argocd-notifications-controller-network-policy
          internal.config.kubernetes.io/previousNamespaces: argocd
      newName: "argocd-notifications-controller-network-policy-renamed"
    target:
      kind: NetworkPolicy
      name: argocd-notifications-controller-network-policy
      namespace: argocd
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: NetworkPolicy
      metadata:
        name: cert-manager-allow
        namespace: cert-manager
        annotations:
          internal.config.kubernetes.io/previousKinds: NetworkPolicy
          internal.config.kubernetes.io/previousNames: cert-manager-allow
          internal.config.kubernetes.io/previousNamespaces: cert-manager
      newName: "cert-manager-allow-renamed"
    target:
      kind: NetworkPolicy
      name: cert-manager-allow
      namespace: cert-manager
