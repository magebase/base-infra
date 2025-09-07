---
# AWS credentials secrets for External Secrets Operator
# These secrets contain the access keys for IAM users created by Terraform

apiVersion: v1
kind: Secret
metadata:
  name: genfix-aws-credentials
  namespace: external-secrets-system
type: Opaque
data:
  access-key-id: "${ESO_GENFIX_ACCESS_KEY_ID}"
  secret-access-key: "${ESO_GENFIX_SECRET_ACCESS_KEY}"

---
apiVersion: v1
kind: Secret
metadata:
  name: site-aws-credentials
  namespace: external-secrets-system
type: Opaque
data:
  access-key-id: "${ESO_SITE_ACCESS_KEY_ID}"
  secret-access-key: "${ESO_SITE_SECRET_ACCESS_KEY}"

---
# Template for additional client AWS credentials
# Copy this block and modify for new clients
apiVersion: v1
kind: Secret
metadata:
  name: ${CLIENT_NAME}-aws-credentials
  namespace: external-secrets-system
type: Opaque
data:
  access-key-id: "${ESO_CLIENT_ACCESS_KEY_ID}"
  secret-access-key: "${ESO_CLIENT_SECRET_ACCESS_KEY}"
