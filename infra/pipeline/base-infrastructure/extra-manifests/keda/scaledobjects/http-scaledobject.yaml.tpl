apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: http-scaledobject
  namespace: default
  labels:
    app.kubernetes.io/name: http-scaledobject
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
  maxReplicaCount: 10
  triggers:
  - type: http
    metadata:
      url: "http://prometheus-operated.kube-prometheus.svc.cluster.local:9090/api/v1/query?query=sum(rate(http_requests_total[5m]))"
      threshold: "100"
      activationThreshold: "50"
      method: "GET"
      timeout: "5000"
      expectedResponseCode: "200"
      allowInsecure: "false"
---
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: http-scaledjob
  namespace: default
  labels:
    app.kubernetes.io/name: http-scaledjob
    app.kubernetes.io/component: autoscaling
    app.kubernetes.io/part-of: keda
spec:
  jobTargetRef:
    template:
      spec:
        template:
          spec:
            containers:
            - name: my-job
              image: busybox
              command: ["echo", "Hello World"]
            restartPolicy: Never
  pollingInterval: 30
  successfulJobsHistoryLimit: 5
  failedJobsHistoryLimit: 5
  maxReplicaCount: 10
  triggers:
  - type: http
    metadata:
      url: "http://prometheus-operated.kube-prometheus.svc.cluster.local:9090/api/v1/query?query=sum(rate(http_requests_total[5m]))"
      threshold: "100"
      activationThreshold: "50"
      method: "GET"
      timeout: "5000"
      expectedResponseCode: "200"
      allowInsecure: "false"
