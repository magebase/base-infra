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
