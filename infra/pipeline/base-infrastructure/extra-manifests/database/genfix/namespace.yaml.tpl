apiVersion: v1
kind: Namespace
metadata:
  name: genfix-${ENVIRONMENT}
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: genfix
    app.kubernetes.io/instance: genfix-${ENVIRONMENT}
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: baseline
    pod-security.kubernetes.io/warn: baseline
