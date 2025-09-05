apiVersion: v1
kind: Secret
metadata:
  name: genfix-backup-secret
  namespace: genfix
type: Opaque
data:
  # Cloudflare R2 credentials for PostgreSQL backups
  access-key-id: "${r2_access_key_id}"
  secret-access-key: "${r2_secret_access_key}"
