apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: argocd
resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
  - letsencrypt-issuer.yaml
  - argocd-certificate.yaml
  - postgresql-certificate.yaml
  - k3s-encryption.yaml
  - network-policies.yaml
  - pod-security.yaml
  - audit-policy.yaml

patches:
  # Patch for custom domain configuration
  - patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env
        value:
          - name: ARGOCD_SERVER_INSECURE
            value: "false"
          - name: ARGOCD_SERVER_ROOTPATH
            value: "/"
    target:
      kind: Deployment
      name: argocd-server
  # Patch for ingress configuration
  - patch: |-
      apiVersion: networking.k8s.io/v1
      kind: Ingress
      metadata:
        name: argocd-server
        namespace: argocd
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-prod
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
          traefik.ingress.kubernetes.io/router.tls: "true"
      spec:
        rules:
          - host: argocd.$(DOMAIN)
            http:
              paths:
                - path: /
                  pathType: Prefix
                  backend:
                    service:
                      name: argocd-server
                      port:
                        number: 443
        tls:
          - hosts:
              - argocd.$(DOMAIN)
            secretName: argocd-tls
    target:
      kind: Ingress
      name: argocd-server
  # Patch for admin password
  - patch: |-
      - op: add
        path: /data
        value:
          admin.password: $(argocd_admin_password)
          admin.passwordMtime: "2025-01-01T00:00:00Z"
    target:
      kind: Secret
      name: argocd-secret
