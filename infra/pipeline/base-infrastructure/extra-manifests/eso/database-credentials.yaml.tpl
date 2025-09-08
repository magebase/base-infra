apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: genfix-database-credentials
  namespace: genfix-${ENVIRONMENT}
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  refreshInterval: "1m"
  secretStoreRef:
    name: genfix-secret-store
    kind: SecretStore
  target:
    name: genfix-database-credentials
    creationPolicy: Owner
  data:
    - secretKey: DATABASE_PASSWORD
      remoteRef:
        key: "/site/${ENVIRONMENT}/genfix/database/password"
        property: ""
    - secretKey: DATABASE_URL
      remoteRef:
        key: "/site/${ENVIRONMENT}/genfix/database/url"
        property: ""
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: site-database-credentials
  namespace: site-${ENVIRONMENT}
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  refreshInterval: "1m"
  secretStoreRef:
    name: site-secret-store
    kind: SecretStore
  target:
    name: site-database-credentials
    creationPolicy: Owner
  data:
    - secretKey: DATABASE_PASSWORD
      remoteRef:
        key: "/site/${ENVIRONMENT}/site/database/password"
        property: ""
    - secretKey: DATABASE_URL
      remoteRef:
        key: "/site/${ENVIRONMENT}/site/database/url"
        property: ""
