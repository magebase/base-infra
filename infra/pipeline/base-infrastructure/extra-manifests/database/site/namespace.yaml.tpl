apiVersion: v1
kind: Namespace
metadata:
  name: site-${ENVIRONMENT}
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: site
    app.kubernetes.io/instance: site-${ENVIRONMENT}
    pod-security.kubernetes.io/enforce: baseline
    pod-security.kubernetes.io/audit: baseline
    pod-security.kubernetes.io/warn: baseline
