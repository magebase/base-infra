apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prometheus-scaledobject
  namespace: default
  labels:
    app.kubernetes.io/name: prometheus-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 1
  maxReplicaCount: 50
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-operated.kube-prometheus.svc.cluster.local:9090
      metricName: http_requests_total
      threshold: "100"
      activationThreshold: "50"
      query: |
        sum(rate(http_requests_total{namespace="default",deployment="my-app-deployment"}[5m]))
      authModes: "bearer"
    authenticationRef:
      name: keda-prometheus-auth
---
apiVersion: v1
kind: Secret
metadata:
  name: keda-prometheus-auth
  namespace: default
type: Opaque
data:
  bearerToken: ""  # Base64 encoded bearer token for Prometheus authentication
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: custom-metric-scaledobject
  namespace: default
  labels:
    app.kubernetes.io/name: custom-metric-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app-deployment
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 1
  maxReplicaCount: 30
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-operated.kube-prometheus.svc.cluster.local:9090
      metricName: queue_length
      threshold: "10"
      activationThreshold: "5"
      query: |
        sum(queue_length{namespace="default",queue="my-queue"})
      authModes: "bearer"
    authenticationRef:
      name: keda-prometheus-auth
