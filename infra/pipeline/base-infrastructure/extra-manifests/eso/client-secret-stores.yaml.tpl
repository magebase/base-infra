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
      role: arn:aws:iam::${AWS_ACCOUNT_ID}:role/external-secrets-genfix
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
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
      role: arn:aws:iam::${AWS_ACCOUNT_ID}:role/external-secrets-site
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
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
      role: arn:aws:iam::${AWS_ACCOUNT_ID}:role/external-secrets-${CLIENT_NAME}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
