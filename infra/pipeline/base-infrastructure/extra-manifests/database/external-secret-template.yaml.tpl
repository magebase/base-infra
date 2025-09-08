apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{CLIENT}}-{{ENVIRONMENT}}-database-secret
  namespace: database
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: {{CLIENT}}-secret-store
    kind: SecretStore
  target:
    name: {{CLIENT}}-{{ENVIRONMENT}}-ssm-database-url
    creationPolicy: Owner
  data:
  - secretKey: DATABASE_URL
    remoteRef:
      key: /{{CLIENT}}/{{ENVIRONMENT}}/database/url
