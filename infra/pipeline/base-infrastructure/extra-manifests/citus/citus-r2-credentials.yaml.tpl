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
---
apiVersion: v1
kind: Secret
metadata:
  namespace: citus
  name: ${MINIO_SECRET_NAME}
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-credentials
type: Opaque
data:
  ${MINIO_ACCESS_KEY}: <base64-encoded-minio-access-key>
  ${MINIO_SECRET_KEY}: <base64-encoded-minio-secret-key>
