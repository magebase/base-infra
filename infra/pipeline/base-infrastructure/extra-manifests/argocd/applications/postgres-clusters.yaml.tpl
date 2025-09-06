apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: postgres-clusters
  namespace: argocd
  annotations:
    # Operator wave: -2 (see postgres-operator.yaml.tpl)
    # Give operator extra time; clusters at internal wave 1.
    argocd.argoproj.io/sync-wave: "-1"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/magebase/site
    path: infra/pipeline/base-infrastructure/extra-manifests/postgres/clusters
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
