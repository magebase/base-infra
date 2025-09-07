# HPA Autoscaling Extension for Knative Serving
# Template for: https://github.com/knative/serving/releases/download/knative-v1.18.1/serving-hpa.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: knative-hpa-autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: knative-hpa-autoscaler
  labels:
    app.kubernetes.io/version: "1.18.1"
rules:
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers"]
  verbs: ["get", "list", "create", "update", "delete", "patch", "watch"]
- apiGroups: ["autoscaling"]
  resources: ["horizontalpodautoscalers/status"]
  verbs: ["get", "update", "patch"]
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["serving.knative.dev"]
  resources: ["services", "services/status", "configurations", "configurations/status", "revisions", "revisions/status"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: knative-hpa-autoscaler
  labels:
    app.kubernetes.io/version: "1.18.1"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: knative-hpa-autoscaler
subjects:
- kind: ServiceAccount
  name: knative-hpa-autoscaler
  namespace: knative-serving

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: knative-hpa-autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: knative-hpa-autoscaler
spec:
  replicas: 1
  selector:
    matchLabels:
      app: knative-hpa-autoscaler
  template:
    metadata:
      labels:
        app: knative-hpa-autoscaler
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: knative-hpa-autoscaler
      containers:
      - name: autoscaler
        image: gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler-hpa@sha256:placeholder
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
apiVersion: v1
kind: Service
metadata:
  name: knative-hpa-autoscaler
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
    app: knative-hpa-autoscaler
spec:
  selector:
    app: knative-hpa-autoscaler
  ports:
  - name: metrics
    port: 9090
    targetPort: 9090

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-hpa-autoscaler
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

    # The HPA class to use.
    hpa-class: "hpa.autoscaling.knative.dev"

    # The minimum replicas for HPA.
    min-scale: "0"

    # The maximum replicas for HPA.
    max-scale: "0"

    # The target CPU utilization percentage.
    target-cpu-utilization-percentage: "80"

    # The target memory utilization percentage.
    target-memory-utilization-percentage: "80"

    # The CPU metric name.
    cpu-metric-name: "cpu"

    # The memory metric name.
    memory-metric-name: "memory"

    # The window size for HPA metrics.
    window: "60s"

    # The panic window for HPA metrics.
    panic-window: "6s"

    # The stabilization window for HPA.
    stabilization-window: "0s"

    # The initial scale for HPA.
    initial-scale: "1"

    # Allow zero initial scale.
    allow-zero-initial-scale: "false"

    # The scale to zero grace period.
    scale-to-zero-grace-period: "30s"

    # The scale to zero pod retention period.
    scale-to-zero-pod-retention-period: "0s"

    # The tick interval for HPA.
    tick-interval: "15s"

    # The downscale stabilization window.
    downscale-stabilization-window: "300s"

    # The upscale stabilization window.
    upscale-stabilization-window: "0s"

    # The behavior for HPA scaling.
    behavior: ""

    # The annotations for HPA.
    annotations: ""

    # The labels for HPA.
    labels: ""
