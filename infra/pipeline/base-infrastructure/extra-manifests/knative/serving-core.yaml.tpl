# Knative Serving Core Components
# Template for: https://github.com/knative/serving/releases/download/knative-v1.18.1/serving-core.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: controller
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: knative-serving-admin
  labels:
    app.kubernetes.io/version: "1.18.1"
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["serving.knative.dev"]
  resources: ["*"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["networking.internal.knative.dev"]
  resources: ["*"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["autoscaling.internal.knative.dev"]
  resources: ["*"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: knative-serving-controller-admin
  labels:
    app.kubernetes.io/version: "1.18.1"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: knative-serving-admin
subjects:
- kind: ServiceAccount
  name: controller
  namespace: knative-serving

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The Revision ContainerConcurrency field specifies the maximum
    # number of concurrent requests allowed per container of a Revision.
    # Container concurrency target percentage.
    # The value specifies a percentage of the ContainerConcurrency
    # to start throttling requests.
    container-concurrency-target-percentage: "70"

    # The container concurrency target default.
    container-concurrency-target-default: "100"

    # The autoscaler class to use.
    autoscaler-class: "kpa.autoscaling.knative.dev"

    # The stable window for request rate calculation.
    stable-window: "60s"

    # The panic window for request rate calculation.
    panic-window: "6s"

    # The panic threshold percentage.
    panic-threshold-percentage: "200"

    # The target burst capacity.
    target-burst-capacity: "200"

    # The requests per second target default.
    requests-per-second-target-default: "200"

    # The target utilization percentage.
    target-utilization-percentage: "70"

    # The RPS target default.
    rps-target-default: "200"

    # The requests per second target default.
    requests-per-second-target-default: "200"

    # Allow zero initial scale.
    allow-zero-initial-scale: "false"

    # The initial scale for a revision.
    initial-scale: "1"

    # The maximum scale for a revision.
    max-scale: "0"

    # The minimum scale for a revision.
    min-scale: "0"

    # Scale to zero grace period.
    scale-to-zero-grace-period: "30s"

    # Scale to zero pod retention period.
    scale-to-zero-pod-retention-period: "0s"

    # The tick interval for the autoscaler.
    tick-interval: "2s"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-defaults
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # Revision Timeout Seconds
    revision-timeout-seconds: "300"

    # Maximum Revision Timeout Seconds
    max-revision-timeout-seconds: "600"

    # Minimum Revision Timeout Seconds
    min-revision-timeout-seconds: "1"

    # Revision CPU Request
    revision-cpu-request: "100m"

    # Revision Memory Request
    revision-memory-request: "128Mi"

    # Revision CPU Limit
    revision-cpu-limit: "1000m"

    # Revision Memory Limit
    revision-memory-limit: "2048Mi"

    # Revision Ephemeral Storage Limit
    revision-ephemeral-storage-limit: "2048Mi"

    # Container Name Template
    container-name-template: "user-container"

    # Container Concurrency
    container-concurrency: "0"

    # Enable Service Links
    enable-service-links: "false"

    # Revision GC Frequency
    revision-gc-frequency: "30s"

    # Max Failed Records
    max-failed-records: "10"

    # Max Revision Container Concurrency
    max-revision-container-concurrency: "0"

    # Init Container Name Template
    init-container-name-template: "init-container"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-deployment
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # Progress deadline for the deployment.
    progress-deadline: "600s"

    # Queue sidecar CPU request.
    queue-sidecar-cpu-request: "25m"

    # Queue sidecar CPU limit.
    queue-sidecar-cpu-limit: "1000m"

    # Queue sidecar memory request.
    queue-sidecar-memory-request: "400Mi"

    # Queue sidecar memory limit.
    queue-sidecar-memory-limit: "2048Mi"

    # Queue sidecar ephemeral storage limit.
    queue-sidecar-ephemeral-storage-limit: "2048Mi"

    # Queue sidecar image.
    queue-sidecar-image: "gcr.io/knative-releases/knative.dev/serving/cmd/queue"

    # Registries skipping tag resolution.
    registries-skipping-tag-resolution: "ko.local,dev.local"

    # Digest resolution timeout.
    digest-resolution-timeout: "10s"

    # Concurrency state endpoint.
    concurrency-state-endpoint: ""

    # Concurrency state TTL.
    concurrency-state-ttl: "3s"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-features
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # Enable Kubernetes Multi-Container Support
    kubernetes.multi-container: "enabled"

    # Enable Kubernetes EmptyDir Support
    kubernetes.podspec-volumes-emptydir: "enabled"

    # Enable Kubernetes ConfigMap Support
    kubernetes.podspec-volumes-configmap: "enabled"

    # Enable Kubernetes Secret Support
    kubernetes.podspec-volumes-secret: "enabled"

    # Enable Kubernetes PVC Support
    kubernetes.podspec-volumes-pvc: "enabled"

    # Enable Kubernetes HostPath Support
    kubernetes.podspec-volumes-hostpath: "enabled"

    # Enable Kubernetes Projected Support
    kubernetes.podspec-volumes-projected: "enabled"

    # Enable Kubernetes Affinity Support
    kubernetes.podspec-affinity: "enabled"

    # Enable Kubernetes Tolerations Support
    kubernetes.podspec-tolerations: "enabled"

    # Enable Kubernetes Topology Spread Constraints Support
    kubernetes.podspec-topology-spread-constraints: "enabled"

    # Enable Kubernetes RuntimeClassName Support
    kubernetes.podspec-runtimeclassname: "enabled"

    # Enable Kubernetes PriorityClassName Support
    kubernetes.podspec-priorityclassname: "enabled"

    # Enable Kubernetes SchedulerName Support
    kubernetes.podspec-schedulername: "enabled"

    # Enable Kubernetes HostAliases Support
    kubernetes.podspec-hostaliases: "enabled"

    # Enable Kubernetes NodeSelector Support
    kubernetes.podspec-nodeselector: "enabled"

    # Enable Kubernetes SecurityContext Support
    kubernetes.podspec-securitycontext: "enabled"

    # Enable Kubernetes DNSPolicy Support
    kubernetes.podspec-dnspolicy: "enabled"

    # Enable Kubernetes DNSConfig Support
    kubernetes.podspec-dnsconfig: "enabled"

    # Enable Kubernetes InitContainers Support
    kubernetes.podspec-init-containers: "enabled"

    # Enable Kubernetes ImagePullSecrets Support
    kubernetes.podspec-imagepullsecrets: "enabled"

    # Enable Kubernetes Liveness Probe Support
    kubernetes.podspec-liveness-probe: "enabled"

    # Enable Kubernetes Readiness Probe Support
    kubernetes.podspec-readiness-probe: "enabled"

    # Enable Kubernetes Startup Probe Support
    kubernetes.podspec-startup-probe: "enabled"

    # Enable Tag to Digest Resolution
    kubernetes.podspec-resolve-tag-to-digest: "enabled"

    # Enable PVC Support
    kubernetes.podspec-pvc: "enabled"

    # Enable HPA Support
    kubernetes.podspec-hpa: "enabled"

    # Enable Multi-Container Support
    multi-container: "enabled"

    # Enable Tag Resolution
    tag-to-digest-resolution: "enabled"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-gc
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The minimum number of non-active revisions to retain.
    min-non-active-revisions: "20"

    # The maximum number of non-active revisions to retain.
    max-non-active-revisions: "1000"

    # The minimum number of active revisions to retain.
    min-active-revisions: "0"

    # The maximum number of active revisions to retain.
    max-active-revisions: "1000"

    # The time to retain a revision after it becomes non-active.
    retain-since-create-time: "48h"

    # The time to retain a revision after it was last referenced.
    retain-since-last-active-time: "15h"

    # The grace period before a revision is deleted.
    retain-since-last-active-time: "15h"

    # The delay before deleting a revision.
    delay-after-last-active: "0s"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-leader-election
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The duration that non-leader candidates will wait to force acquire leadership.
    lease-duration: "15s"

    # The duration that the acting master will retry refreshing leadership before giving up.
    renew-deadline: "10s"

    # The duration the LeaderElector clients should wait between tries of actions.
    retry-period: "2s"

    # The number of concurrent leaders per resource namespace.
    buckets: "1"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-logging
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The logging level for the controller.
    level: "info"

    # The logging level for the webhook.
    webhook.level: "info"

    # The logging level for the activator.
    activator.level: "info"

    # The logging level for the autoscaler.
    autoscaler.level: "info"

    # The logging level for the queue proxy.
    queueproxy.level: "info"

    # The logging level for the domain mapping.
    domainmapping.level: "info"

    # The logging level for the domain mapping webhook.
    domainmappingwebhook.level: "info"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The ingress class to use for Knative services.
    ingress-class: "istio.ingress.networking.knative.dev"

    # The domain template for Knative services.
    domain-template: "{{.Name}}.{{.Namespace}}.{{.Domain}}"

    # The default domain for Knative services.
    default-external-domain: ""

    # The auto TLS setting.
    auto-tls: "Disabled"

    # The HTTP protocol for Knative services.
    http-protocol: "http"

    # The cluster local domain TLS setting.
    cluster-local-domain-tls: "Disabled"

    # The system internal TLS setting.
    system-internal-tls: "Disabled"

    # The rollout duration for networking changes.
    rollout-duration: "0s"

    # The namespace wildcard certificate name.
    namespace-wildcard-cert-selector: ""

    # The label key for domain.
    label-key-domain: "networking.knative.dev/disableWildcardCert"

    # The label key for wildcard cert.
    label-key-wildcard-cert: "networking.knative.dev/wildcardCertificate"

    # The label key for visibility.
    label-key-visibility: "networking.knative.dev/visibility"

    # The visibility for cluster local services.
    cluster-local-domain-tls: "cluster-local"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-observability
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The logging level for the controller.
    logging.enable-request-log: "false"

    # The request log template.
    logging.request-log-template: '{"httpRequest": {"requestMethod": "{{.Request.Method}}", "requestUrl": "{{js .Request.RequestURI}}", "requestSize": "{{.Request.ContentLength}}", "status": {{.Response.Code}}, "responseSize": "{{.Response.Size}}", "userAgent": "{{js .Request.UserAgent}}", "remoteIp": "{{js .Request.RemoteAddr}}", "serverIp": "{{.Revision.PodIP}}", "referer": "{{js .Request.Referer}}", "latency": "{{.Response.Latency}}", "protocol": "{{.Request.Proto}}"}, "traceId": "{{index .Request.Header "X-B3-Traceid"}}"}'

    # The request metrics backend.
    metrics.request-metrics-backend-destination: "prometheus"

    # The request metrics reporting period.
    metrics.request-metrics-reporting-period-seconds: "1"

    # The request metrics reporting period.
    metrics.request-metrics-reporting-period-seconds: "1"

    # The profiling port.
    profiling.enable: "false"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: activator
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: activator
spec:
  replicas: 1
  selector:
    matchLabels:
      app: activator
  template:
    metadata:
      labels:
        app: activator
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: controller
      containers:
      - name: activator
        image: gcr.io/knative-releases/knative.dev/serving/cmd/activator@sha256:placeholder
        ports:
        - containerPort: 9090
          name: metrics
        - containerPort: 8008
          name: profiling
        - containerPort: 8080
          name: http1
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: SYSTEM_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CONFIG_LOGGING_NAME
          value: config-logging
        - name: CONFIG_OBSERVABILITY_NAME
          value: config-observability
        - name: METRICS_DOMAIN
          value: knative.dev/serving
        resources:
          requests:
            cpu: 300m
            memory: 60Mi
          limits:
            cpu: 1000m
            memory: 600Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
            port: 9090
            path: /readiness
          periodSeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            port: 9090
            path: /health
          periodSeconds: 15
          timeoutSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: autoscaler
  template:
    metadata:
      labels:
        app: autoscaler
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: controller
      containers:
      - name: autoscaler
        image: gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler@sha256:placeholder
        ports:
        - containerPort: 9090
          name: metrics
        - containerPort: 8008
          name: profiling
        - containerPort: 8080
          name: websocket
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: SYSTEM_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CONFIG_LOGGING_NAME
          value: config-logging
        - name: CONFIG_OBSERVABILITY_NAME
          value: config-observability
        - name: METRICS_DOMAIN
          value: knative.dev/serving
        resources:
          requests:
            cpu: 30m
            memory: 40Mi
          limits:
            cpu: 300m
            memory: 400Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
            port: 9090
            path: /readiness
          periodSeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            port: 9090
            path: /health
          periodSeconds: 15
          timeoutSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: controller
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: controller
  template:
    metadata:
      labels:
        app: controller
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: controller
      containers:
      - name: controller
        image: gcr.io/knative-releases/knative.dev/serving/cmd/controller@sha256:placeholder
        ports:
        - containerPort: 9090
          name: metrics
        - containerPort: 8008
          name: profiling
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: SYSTEM_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CONFIG_LOGGING_NAME
          value: config-logging
        - name: CONFIG_OBSERVABILITY_NAME
          value: config-observability
        - name: METRICS_DOMAIN
          value: knative.dev/serving
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 1000m
            memory: 1000Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
            port: 9090
            path: /readiness
          periodSeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            port: 9090
            path: /health
          periodSeconds: 15
          timeoutSeconds: 5

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webhook
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: webhook
spec:
  replicas: 1
  selector:
    matchLabels:
      app: webhook
  template:
    metadata:
      labels:
        app: webhook
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: controller
      containers:
      - name: webhook
        image: gcr.io/knative-releases/knative.dev/serving/cmd/webhook@sha256:placeholder
        ports:
        - containerPort: 9090
          name: metrics
        - containerPort: 8008
          name: profiling
        - containerPort: 8443
          name: https-webhook
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: SYSTEM_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: CONFIG_LOGGING_NAME
          value: config-logging
        - name: CONFIG_OBSERVABILITY_NAME
          value: config-observability
        - name: METRICS_DOMAIN
          value: knative.dev/serving
        - name: WEBHOOK_NAME
          value: webhook
        - name: WEBHOOK_PORT
          value: "8443"
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 500m
            memory: 500Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
            port: 9090
            path: /readiness
            scheme: HTTPS
          periodSeconds: 15
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            port: 9090
            path: /health
            scheme: HTTPS
          periodSeconds: 15
          timeoutSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: activator-service
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: activator
spec:
  selector:
    app: activator
  ports:
  - name: http
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443
  - name: metrics
    port: 9090
    targetPort: 9090

---
apiVersion: v1
kind: Service
metadata:
  name: autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: autoscaler
spec:
  selector:
    app: autoscaler
  ports:
  - name: websocket
    port: 8080
    targetPort: 8080
  - name: metrics
    port: 9090
    targetPort: 9090

---
apiVersion: v1
kind: Service
metadata:
  name: controller
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: controller
spec:
  selector:
    app: controller
  ports:
  - name: metrics
    port: 9090
    targetPort: 9090

---
apiVersion: v1
kind: Service
metadata:
  name: webhook
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: webhook
spec:
  selector:
    app: webhook
  ports:
  - name: http
    port: 80
    targetPort: 8443
  - name: metrics
    port: 9090
    targetPort: 9090

---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: config.webhook.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
webhooks:
- admissionReviewVersions:
  - v1
  - v1beta1
  clientConfig:
    service:
      name: webhook
      namespace: knative-serving
  failurePolicy: Fail
  name: config.webhook.serving.knative.dev
  rules:
  - apiGroups:
    - serving.knative.dev
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - configurations
  sideEffects: None

---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: validation.webhook.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
webhooks:
- admissionReviewVersions:
  - v1
  - v1beta1
  clientConfig:
    service:
      name: webhook
      namespace: knative-serving
  failurePolicy: Fail
  name: validation.webhook.serving.knative.dev
  rules:
  - apiGroups:
    - serving.knative.dev
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - services
    - configurations
    - revisions
  sideEffects: None

---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: webhook.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
webhooks:
- admissionReviewVersions:
  - v1
  - v1beta1
  clientConfig:
    service:
      name: webhook
      namespace: knative-serving
  failurePolicy: Fail
  name: webhook.serving.knative.dev
  rules:
  - apiGroups:
    - serving.knative.dev
    apiVersions:
    - v1
    operations:
    - CREATE
    - UPDATE
    resources:
    - services
    - configurations
    - revisions
  sideEffects: None
