apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: stackgres-operator
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://stackgres.io/downloads/stackgres-k8s/stackgres/helm/
    chart: stackgres-operator
    targetRevision: 1.17.2
    helm:
      releaseName: stackgres-operator
      values: |
        installCRDs: true
        operator:
          replicaCount: 1
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 100m
              memory: 256Mi
        restapi:
          enabled: true
          replicaCount: 1
          resources:
            limits:
              cpu: 200m
              memory: 256Mi
            requests:
              cpu: 50m
              memory: 128Mi
        adminui:
          enabled: false
        serviceMonitor:
          enabled: false
        prometheusAutobind:
          enabled: false
  destination:
    server: https://kubernetes.default.svc
    namespace: stackgres
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
      - Replace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
