apiVersion: v1
kind: Secret
metadata:
  namespace: database
  name: ${CLUSTER_NAME}-db-url
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: database-url
    app.kubernetes.io/part-of: ${APP_NAME}
    environment: ${ENVIRONMENT}
type: Opaque
data:
  # Database connection URL for in-cluster access
  # Format: postgresql://username:password@service-name.database:5432/database
  DATABASE_URL: placeholder
