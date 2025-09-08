apiVersion: v1
kind: Namespace
metadata:
  name: stackgres
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: stackgres
    app.kubernetes.io/instance: stackgres-${ENVIRONMENT}
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/warn: privileged
