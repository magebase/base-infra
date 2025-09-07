apiVersion: v1
kind: Secret
metadata:
  name: awssm-secret
  namespace: external-secrets-system
stringData:
  access-key: ${AWS_ACCESS_KEY_ID}
  secret-access-key: ${AWS_SECRET_ACCESS_KEY}
---
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: aws-parameterstore
  namespace: external-secrets-system
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: awssm-secret
            key: access-key
          secretAccessKeySecretRef:
            name: awssm-secret
            key: secret-access-key
