apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: yugabyte-tserver-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: yugabyte-tserver-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: genfix-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 5
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus-operated.kube-prometheus.svc.cluster.local:9090
      metricName: yugabyte_tserver_connections_active
      threshold: "10"
      activationThreshold: "5"
      query: |
        sum(yugabyte_tserver_connections_active{namespace="yb",cluster="genfix-cluster"})
      authModes: "bearer"
    authenticationRef:
      name: keda-prometheus-auth
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: yugabyte-cpu-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: yugabyte-cpu-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: genfix-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 5
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "70"
      activationThreshold: "30"
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: yugabyte-memory-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: yugabyte-memory-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: genfix-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 5
  triggers:
  - type: memory
    metadata:
      type: Utilization
      value: "80"
      activationThreshold: "40"
