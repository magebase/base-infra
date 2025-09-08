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
  accessKey: ${R2_ACCESS_KEY_ID}
  secretKey: ${R2_SECRET_ACCESS_KEY}
