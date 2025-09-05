apiVersion: v1
kind: Secret
metadata:
  name: site-backup-secret
  namespace: site
type: Opaque
data:
  # Cloudflare R2 credentials for PostgreSQL backups
  access-key-id: "${r2_access_key_id}"
  secret-access-key: "${r2_secret_access_key}"
