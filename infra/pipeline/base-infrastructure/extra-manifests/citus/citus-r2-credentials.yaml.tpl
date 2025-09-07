apiVersion: v1
kind: Secret
metadata:
  namespace: citus
  name: citus-r2-credentials
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-credentials
type: Opaque
data:
  accessKey: <base64-encoded-access-key>
  secretKey: <base64-encoded-secret-key>
