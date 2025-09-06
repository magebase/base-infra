apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: magebase-site-${environment}-fsn1
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
    targetRevision: ${SITE_TARGET_REVISION}
  destination:
    server: https://fsn1-${environment}-magebase-k8s:6443
    namespace: site-${environment}
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
