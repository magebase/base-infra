# Certificate debugging and monitoring resources
# This file contains resources to help debug certificate issues

---
# ServiceMonitor for cert-manager metrics (if Prometheus is available)
apiVersion: v1
kind: ServiceMonitor
metadata:
  name: cert-manager-metrics
  namespace: cert-manager
  labels:
    app.kubernetes.io/name: cert-manager
    app.kubernetes.io/instance: cert-manager
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: cert-manager
      app.kubernetes.io/instance: cert-manager
  endpoints:
  - port: tcp-prometheus-servicemonitor
    interval: 60s
    path: /metrics

---
# ConfigMap with debugging scripts for certificate troubleshooting
apiVersion: v1
kind: ConfigMap
metadata:
  name: cert-debug-scripts
  namespace: cert-manager
  labels:
    app.kubernetes.io/name: cert-manager-debug
data:
  debug-certificates.sh: |
    #!/bin/bash

    echo "=== Certificate Debug Information ==="
    echo

    echo "1. Checking ClusterIssuers:"
    kubectl get clusterissuer -o wide
    echo

    echo "2. Checking Certificates:"
    kubectl get certificates -A -o wide
    echo

    echo "3. Checking Certificate Requests:"
    kubectl get certificaterequests -A -o wide
    echo

    echo "4. Checking ACME Orders:"
    kubectl get orders -A -o wide
    echo

    echo "5. Checking ACME Challenges:"
    kubectl get challenges -A -o wide
    echo

    echo "6. Checking ArgoCD Certificate Details:"
    kubectl describe certificate argocd-tls -n argocd
    echo

    echo "7. Checking ArgoCD Certificate Secret:"
    kubectl describe secret argocd-tls -n argocd
    echo

    echo "8. Checking cert-manager logs:"
    kubectl logs -n cert-manager deployment/cert-manager --tail=50
    echo

    echo "9. Checking Cloudflare secret:"
    kubectl get secret cloudflare-api-token-secret -n cert-manager -o yaml
    echo

    echo "=== End Debug Information ==="

  check-dns-propagation.sh: |
    #!/bin/bash

    DOMAIN="$${1:-argocd.dev.magebase.dev}"

    echo "Checking DNS propagation for $$DOMAIN"
    echo

    echo "DNS A records:"
    dig +short A $$DOMAIN
    echo

    echo "DNS CNAME records:"
    dig +short CNAME $$DOMAIN
    echo

    echo "DNS TXT records (for ACME challenges):"
    dig +short TXT "_acme-challenge.$$DOMAIN"
    echo

---
# Job to run certificate debugging (can be triggered manually)
apiVersion: batch/v1
kind: Job
metadata:
  name: cert-debug-${environment}
  namespace: cert-manager
  labels:
    app.kubernetes.io/name: cert-manager-debug
    environment: ${environment}
spec:
  template:
    metadata:
      labels:
        app.kubernetes.io/name: cert-manager-debug
    spec:
      serviceAccountName: cert-manager-debug
      containers:
      - name: debug
        image: bitnami/kubectl:latest
        command: ["/bin/bash"]
        args: ["/scripts/debug-certificates.sh"]
        volumeMounts:
        - name: debug-scripts
          mountPath: /scripts
      volumes:
      - name: debug-scripts
        configMap:
          name: cert-debug-scripts
          defaultMode: 0755
      restartPolicy: Never
  backoffLimit: 1

---
# ServiceAccount for debugging job
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cert-manager-debug
  namespace: cert-manager
  labels:
    app.kubernetes.io/name: cert-manager-debug

---
# ClusterRole for certificate debugging
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cert-manager-debug
  labels:
    app.kubernetes.io/name: cert-manager-debug
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps", "events"]
  verbs: ["get", "list", "describe"]
- apiGroups: ["cert-manager.io"]
  resources: ["certificates", "certificaterequests", "issuers", "clusterissuers"]
  verbs: ["get", "list", "describe"]
- apiGroups: ["acme.cert-manager.io"]
  resources: ["orders", "challenges"]
  verbs: ["get", "list", "describe"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]

---
# ClusterRoleBinding for debugging
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cert-manager-debug
  labels:
    app.kubernetes.io/name: cert-manager-debug
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cert-manager-debug
subjects:
- kind: ServiceAccount
  name: cert-manager-debug
  namespace: cert-manager
