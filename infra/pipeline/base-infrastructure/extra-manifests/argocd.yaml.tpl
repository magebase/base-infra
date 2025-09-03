---
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
  labels:
    name: argocd
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: argocd
  namespace: argocd
spec:
  chart: argo-cd
  repo: https://argoproj.github.io/argo-helm
  targetNamespace: argocd
  version: "7.3.11"
  valuesContent: |
    server:
      service:
        type: ClusterIP
      ingress:
        enabled: true
        hosts:
          - argocd.$(DOMAIN)
        tls:
          - secretName: argocd-tls
            hosts:
              - argocd.$(DOMAIN)
    configs:
      secret:
        argocdServerAdminPassword: $(ARGOCD_ADMIN_PASSWORD)
    dex:
      enabled: false
    # Install CRDs
    crds:
      install: true
      keep: true
