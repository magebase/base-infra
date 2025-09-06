apiVersion: v1
kind: Secret
metadata:
  name: site-backup-secret
  namespace: site-${ENVIRONMENT}
type: Opaque
data:
  # Cloudflare R2 credentials for PostgreSQL backups
  access-key-id: "${R2_ACCESS_KEY_ID}"
  secret-access-key: "${R2_SECRET_ACCESS_KEY}"
