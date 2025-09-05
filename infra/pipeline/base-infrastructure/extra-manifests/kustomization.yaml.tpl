apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

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

# Apply namespace transformation to all ArgoCD components
namespace: argocd

# Use strategic merge patches to fix NetworkPolicy namespaces without conflicts
patchesStrategicMerge:
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-application-controller-network-policy
      namespace: argocd
    spec:
      ingress:
      - from:
        - namespaceSelector: {}
        ports:
        - port: 8082
          protocol: TCP
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-applicationset-controller-network-policy
      namespace: argocd
    spec:
      ingress:
      - from:
        - namespaceSelector: {}
        ports:
        - port: 7000
          protocol: TCP
        - port: 8080
          protocol: TCP
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-dex-server-network-policy
      namespace: argocd
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-notifications-controller-network-policy
      namespace: argocd
    spec:
      ingress:
      - from:
        - namespaceSelector: {}
        ports:
        - port: 9001
          protocol: TCP
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-redis-network-policy
      namespace: argocd
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-repo-server-network-policy
      namespace: argocd
  - |-
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: argocd-server-network-policy
      namespace: argocd
    spec:
      ingress:
      - {}

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
