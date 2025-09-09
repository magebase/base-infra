apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: magebase-site-${ENVIRONMENT}-fsn1
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "3"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/magebase/site
    path: k8s
    targetRevision: ${SITE_TARGET_REVISION_DEV}
  destination:
    server: https://kubernetes.default.svc
    namespace: site-${ENVIRONMENT}
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
