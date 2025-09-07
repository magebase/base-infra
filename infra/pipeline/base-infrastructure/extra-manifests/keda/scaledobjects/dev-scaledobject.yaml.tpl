apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: dev-cpu-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: dev-cpu-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: dev-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 3
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "60"
      activationThreshold: "20"
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: dev-memory-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: dev-memory-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: dev-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 3
  triggers:
  - type: memory
    metadata:
      type: Utilization
      value: "70"
      activationThreshold: "30"
