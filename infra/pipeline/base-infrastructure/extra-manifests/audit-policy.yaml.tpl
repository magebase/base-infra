apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-policy
  namespace: kube-system
data:
  audit-policy.yaml: |
    apiVersion: audit.k8s.io/v1
    kind: Policy
    rules:
    - level: Metadata
      verbs: ["create", "update", "patch", "delete"]
      resources:
      - group: ""
        resources: ["secrets", "configmaps"]
    - level: RequestResponse
      verbs: ["create", "update", "patch"]
      resources:
      - group: ""
        resources: ["pods", "deployments", "services"]
      - group: "networking.k8s.io"
        resources: ["networkpolicies", "ingresses"]
    - level: Metadata
      verbs: ["get", "list", "watch"]
      userGroups: ["system:authenticated"]
      resources:
      - group: ""
        resources: ["secrets"]
    - level: None
      verbs: ["get", "list", "watch"]
      resources:
      - group: ""
        resources: ["events"]
      - group: "cert-manager.io"
        resources: ["*"]
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: audit-webhook-config
  namespace: kube-system
data:
  webhook-config.yaml: |
    apiVersion: v1
    kind: Config
    clusters:
    - cluster:
        certificate-authority: /etc/kubernetes/ssl/ca.crt
        server: https://audit-collector.kube-system.svc.cluster.local:443
      name: audit-collector
    contexts:
    - context:
        cluster: audit-collector
        user: audit-collector
      name: audit-collector
    current-context: audit-collector
    users:
    - name: audit-collector
      user:
        client-certificate: /etc/kubernetes/ssl/audit-collector.crt
        client-key: /etc/kubernetes/ssl/audit-collector.key
