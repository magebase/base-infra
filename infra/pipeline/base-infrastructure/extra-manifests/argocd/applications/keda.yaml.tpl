apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: keda
  namespace: argocd
  labels:
    app.kubernetes.io/name: keda
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  project: default
  source:
    chart: keda
    repoURL: https://kedacore.github.io/charts
    targetRevision: 2.13.0
    helm:
      values: |
        # KEDA Core configuration
        operatorName: keda-operator
        serviceAccount:
          create: true
          name: keda-operator

        # Enable Prometheus metrics
        prometheus:
          operator:
            enabled: true
            port: 8080
          metricServer:
            enabled: true
            port: 8080

        # Webhooks configuration
        webhooks:
          enabled: true

        # RBAC configuration
        rbac:
          create: true

        # Pod Security Context
        podSecurityContext:
          runAsNonRoot: true
          runAsUser: 1001
          runAsGroup: 1001

        # Security Context
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1001
          runAsGroup: 1001
          capabilities:
            drop:
            - ALL

        # Resources
        resources:
          limits:
            cpu: 1000m
            memory: 1000Mi
          requests:
            cpu: 100m
            memory: 128Mi

        # Node Selector (optional)
        nodeSelector: {}

        # Tolerations (optional)
        tolerations: []

        # Affinity (optional)
        affinity: {}

        # Additional environment variables
        env:
        - name: WATCH_NAMESPACE
          value: ""

        # Custom annotations
        podAnnotations: {}

        # Custom labels
        podLabels: {}

        # Image configuration
        image:
          repository: ghcr.io/kedacore/keda
          tag: "2.13.0"
          pullPolicy: IfNotPresent

        # Service configuration
        service:
          type: ClusterIP
          port: 443
          targetPort: 9443
          annotations: {}

        # Ingress configuration (optional)
        ingress:
          enabled: false

        # Certificate configuration
        certificate:
          enabled: false

  destination:
    server: https://kubernetes.default.svc
    namespace: keda-system

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
