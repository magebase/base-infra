apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keda-scaledobjects
  namespace: argocd
  labels:
    app.kubernetes.io/name: keda-scaledobjects
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/base-infra
    targetRevision: HEAD
    path: infra/pipeline/base-infrastructure/extra-manifests/keda
  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=false
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
