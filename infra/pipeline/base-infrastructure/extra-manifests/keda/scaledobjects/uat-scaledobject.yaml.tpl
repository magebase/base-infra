apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: uat-cpu-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: uat-cpu-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: uat-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 4
  triggers:
  - type: cpu
    metadata:
      type: Utilization
      value: "65"
      activationThreshold: "25"
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: uat-memory-scaledobject
  namespace: yb
  labels:
    app.kubernetes.io/name: uat-memory-scaledobject
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  scaleTargetRef:
    apiVersion: yugabyte.com/v1alpha1
    kind: YBCluster
    name: uat-cluster
  pollingInterval: 30
  cooldownPeriod: 300
  minReplicaCount: 0  # Allow scaling to zero
  maxReplicaCount: 4
  triggers:
  - type: memory
    metadata:
      type: Utilization
      value: "75"
      activationThreshold: "35"
