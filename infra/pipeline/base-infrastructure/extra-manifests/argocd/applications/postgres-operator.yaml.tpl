apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: yugabyte-db
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    chart: yugabyte
    repoURL: https://charts.yugabyte.com
    targetRevision: 2.25.2
    helm:
      values: |
        replicas:
          master: 3
          tserver: 3
        storage:
          master:
            size: 10Gi
            storageClass: standard
          tserver:
            size: 10Gi
            storageClass: standard
        resource:
          master:
            requests:
              cpu: 2
              memory: 2Gi
            limits:
              cpu: 2
              memory: 2Gi
          tserver:
            requests:
              cpu: 2
              memory: 4Gi
            limits:
              cpu: 2
              memory: 4Gi
        enableLoadBalancer: true
  destination:
    server: https://kubernetes.default.svc
    namespace: yb-demo
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
