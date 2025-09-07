apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prod-cpu-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: prod-cpu-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: prod-cluster
  pollingInterval: 30
  cooldownPeriod: 600  # Longer cooldown for production
  minReplicaCount: 1   # Keep at least 1 replica in production
  maxReplicaCount: 10
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "75"
      activationThreshold: "40"
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: prod-memory-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: prod-memory-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: prod-cluster
  pollingInterval: 30
  cooldownPeriod: 600  # Longer cooldown for production
  minReplicaCount: 1   # Keep at least 1 replica in production
  maxReplicaCount: 10
  triggers:
  - type: memory
    metadata:
      type: Utilization
      value: "85"
      activationThreshold: "50"
