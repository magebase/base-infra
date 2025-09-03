apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: argocd
  namespace: argocd
spec:
  repo: https://argoproj.github.io/argo-helm
  chart: argo-cd
  targetNamespace: argocd
  valuesContent: |-
    global:
      domain: argocd.$(DOMAIN)
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
