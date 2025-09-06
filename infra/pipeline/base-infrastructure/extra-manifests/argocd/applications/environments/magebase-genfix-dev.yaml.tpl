apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: magebase-genfix-dev
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "3"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/magebase/genfix
    path: k8s
    targetRevision: v1.2.3
  destination:
    server: https://kubernetes.default.svc
    namespace: genfix-dev
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
