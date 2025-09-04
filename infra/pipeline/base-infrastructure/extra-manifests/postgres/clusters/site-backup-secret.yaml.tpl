apiVersion: v1
kind: Secret
metadata:
  name: site-backup-secret
  namespace: site
type: Opaque
data:
  # These should be populated with actual AWS credentials
  access-key-id: ""
  secret-access-key: ""
