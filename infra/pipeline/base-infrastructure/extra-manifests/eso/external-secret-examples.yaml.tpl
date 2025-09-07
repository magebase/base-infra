# Example ExternalSecret for database credentials
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: ${CLIENT_NAME}-${ENVIRONMENT}
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: ${CLIENT_NAME}-secret-store
    kind: SecretStore
  target:
    name: database-credentials
    creationPolicy: Owner
  data:
  - secretKey: username
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/database/username
  - secretKey: password
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/database/password
  - secretKey: host
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/database/host
  - secretKey: port
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/database/port

---
# Example ExternalSecret for API keys
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: api-keys
  namespace: ${CLIENT_NAME}-${ENVIRONMENT}
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: ${CLIENT_NAME}-secret-store
    kind: SecretStore
  target:
    name: api-keys
    creationPolicy: Owner
  data:
  - secretKey: stripe-secret-key
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/api/stripe-secret-key
  - secretKey: github-token
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/api/github-token

---
# Example ExternalSecret for JSON-based configuration
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: app-config
  namespace: ${CLIENT_NAME}-${ENVIRONMENT}
spec:
  refreshInterval: 30m
  secretStoreRef:
    name: ${CLIENT_NAME}-secret-store
    kind: SecretStore
  target:
    name: app-config
    creationPolicy: Owner
  data:
  - secretKey: redis-url
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/config/redis
      property: url
  - secretKey: redis-password
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/config/redis
      property: password
  - secretKey: smtp-host
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/config/smtp
      property: host
  - secretKey: smtp-port
    remoteRef:
      key: /${CLIENT_NAME}/${ENVIRONMENT}/config/smtp
      property: port
