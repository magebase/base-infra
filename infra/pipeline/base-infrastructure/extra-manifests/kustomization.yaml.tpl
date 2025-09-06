apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v3.1.1/manifests/install.yaml
  - cloudflare-secret.yaml
  - postgresql-certificate.yaml
  - argocd-certificate.yaml
  - k3s-encryption.yaml
  - network-policies.yaml
  - argocd-network-policies.yaml
  - pod-security.yaml
  - audit-policy.yaml
  - argocd-ingress.yaml
  - traefik-middleware.yaml
  - argocd/github-pat-secret.yaml
  - argocd/applications/app-of-apps.yaml
  - argocd/applications/trivy-operator.yaml
  - argocd/applications/kube-prometheus.yaml
  - argocd/applications/postgres-operator.yaml
  - argocd/applications/postgres-clusters.yaml
  # Environment-specific applications (segregated by app)
  - argocd/applications/environments/genfix/${ENVIRONMENT}-fsn1.yaml
  - argocd/applications/environments/site/${ENVIRONMENT}-fsn1.yaml
  # NOTE: PostgreSQL clusters & backup secrets are now managed exclusively via the
  # ArgoCD Application "postgres-clusters" (see applications/postgres-clusters.yaml.tpl).
  # They were removed from this base kustomization to prevent race conditions where
  # Cluster CRDs (installed by the CloudNativePG operator) were not yet present,
  # producing errors like:
  #   no matches for kind "Cluster" in version "postgresql.cnpg.io/v1"
  # Backup secrets and cluster manifests live under
  # infra/pipeline/base-infrastructure/extra-manifests/postgres/clusters and will
  # be applied only after the operator is installed.

secretGenerator:
  - name: argocd-secret
    behavior: merge
    literals:
      - admin.password=${ARGOCD_ADMIN_PASSWORD}
      - admin.passwordMtime=MjAyNS0wMS0wMVQwMDowMDowMFo=
      - server.insecure=true
    options:
      disableNameSuffixHash: true

# Apply namespace transformation to all ArgoCD components
namespace: argocd

## NOTE:
## We previously attempted to supply our own NetworkPolicies and rename upstream ones.
## That produced an accumulation (ID conflict) error because kustomize detects duplicate
## GVK/namespace/name before applying JSON6902 rename patches. Instead we now keep the
## upstream NetworkPolicies and patch their specs directly to match our desired rules.

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
  # NetworkPolicy: application-controller
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-application-controller
          ingress:
            - from:
                - namespaceSelector: {}
              ports:
                - port: 8082
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-application-controller-network-policy
  # NetworkPolicy: applicationset-controller
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-applicationset-controller
          ingress:
            - from:
                - namespaceSelector: {}
              ports:
                - port: 7000
                  protocol: TCP
                - port: 8080
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-applicationset-controller-network-policy
  # NetworkPolicy: dex-server
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-dex-server
          ingress:
            - from:
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-server
              ports:
                - port: 5556
                  protocol: TCP
                - port: 5557
                  protocol: TCP
            - from:
                - namespaceSelector: {}
              ports:
                - port: 5558
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-dex-server-network-policy
  # NetworkPolicy: notifications-controller
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-notifications-controller
          ingress:
            - from:
                - namespaceSelector: {}
              ports:
                - port: 9001
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-notifications-controller-network-policy
  # NetworkPolicy: redis
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-redis
          ingress:
            - from:
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-server
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-repo-server
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-application-controller
              ports:
                - port: 6379
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-redis-network-policy
  # NetworkPolicy: repo-server
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-repo-server
          ingress:
            - from:
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-server
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-application-controller
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-notifications-controller
                - podSelector:
                    matchLabels:
                      app.kubernetes.io/name: argocd-applicationset-controller
              ports:
                - port: 8081
                  protocol: TCP
            - from:
                - namespaceSelector: {}
              ports:
                - port: 8084
                  protocol: TCP
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-repo-server-network-policy
  # NetworkPolicy: server
  - patch: |-
      - op: replace
        path: /spec
        value:
          podSelector:
            matchLabels:
              app.kubernetes.io/name: argocd-server
          ingress:
            - {}
          policyTypes:
            - Ingress
    target:
      group: networking.k8s.io
      version: v1
      kind: NetworkPolicy
      name: argocd-server-network-policy
