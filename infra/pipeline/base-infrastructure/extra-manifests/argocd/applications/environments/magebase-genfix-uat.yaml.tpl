apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: magebase-genfix-uat
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
    targetRevision: HEAD
  destination:
    server: https://kubernetes.default.svc
    namespace: genfix-uat
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
