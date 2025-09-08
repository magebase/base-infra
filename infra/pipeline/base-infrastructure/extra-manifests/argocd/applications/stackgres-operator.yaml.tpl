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
          resources:
            limits:
              cpu: 500m
              memory: 512Mi
            requests:
              cpu: 100m
              memory: 256Mi
        restapi:
          resources:
            limits:
              cpu: 200m
              memory: 256Mi
            requests:
              cpu: 50m
              memory: 128Mi
        adminui:
          service:
            exposeHTTP: false
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
      - ServerSideApply=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
