apiVersion: v1
kind: Namespace
metadata:
  name: database
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: database
    app.kubernetes.io/instance: database-${ENVIRONMENT}
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: baseline
    pod-security.kubernetes.io/warn: baseline
