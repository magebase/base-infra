apiVersion: v1
kind: Secret
metadata:
  name: genfix-backup-secret
  namespace: genfix
type: Opaque
data:
  # These should be populated with actual AWS credentials
  access-key-id: ""
  secret-access-key: ""
