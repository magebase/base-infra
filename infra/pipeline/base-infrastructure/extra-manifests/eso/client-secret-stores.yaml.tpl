# Client-specific SecretStores with scoped IAM roles
# Each client gets their own SecretStore with limited access to their parameters

---
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: genfix-secret-store
  namespace: external-secrets-system
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: genfix-aws-credentials
            key: access-key-id
          secretAccessKeySecretRef:
            name: genfix-aws-credentials
            key: secret-access-key

---
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: site-secret-store
  namespace: external-secrets-system
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: site-aws-credentials
            key: access-key-id
          secretAccessKeySecretRef:
            name: site-aws-credentials
            key: secret-access-key

---
# Template for additional client secret stores
# Copy this block and modify for new clients
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: ${CLIENT_NAME}-secret-store
  namespace: external-secrets-system
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: ${CLIENT_NAME}-aws-credentials
            key: access-key-id
          secretAccessKeySecretRef:
            name: ${CLIENT_NAME}-aws-credentials
            key: secret-access-key
