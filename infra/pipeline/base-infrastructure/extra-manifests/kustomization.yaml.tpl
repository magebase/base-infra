apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: argocd
resources:
  - namespace.yaml
  - https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml

patches:
  # Middleware to handle ArgoCD headers properly
  - patch: |-
      apiVersion: traefik.containo.us/v1alpha1
      kind: Middleware
      metadata:
        name: argocd-headers
        namespace: argocd
      spec:
        headers:
          customRequestHeaders:
            X-Forwarded-Proto: "http"
          customResponseHeaders:
            Strict-Transport-Security: ""
    target:
      kind: Middleware
      name: argocd-headers
  # Patch for custom domain configuration
  - patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/env
        value:
          - name: ARGOCD_SERVER_INSECURE
            value: "true"
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
          traefik.ingress.kubernetes.io/router.entrypoints: web
          traefik.ingress.kubernetes.io/router.middlewares: argocd-headers@kubernetescrd
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
                        number: 80
        # TLS termination handled by load balancer
        # tls:
        #   - hosts:
        #       - argocd.$(DOMAIN)
        #     secretName: argocd-tls
    target:
      kind: Ingress
      name: argocd-server
  # Patch for admin password
  - patch: |-
      - op: add
        path: /data
        value:
          admin.password: $(ARGOCD_ADMIN_PASSWORD)
          admin.passwordMtime: "2025-01-01T00:00:00Z"
    target:
      kind: Secret
      name: argocd-secret
