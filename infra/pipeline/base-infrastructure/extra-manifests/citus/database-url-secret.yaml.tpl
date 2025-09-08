apiVersion: v1
kind: Secret
metadata:
  namespace: citus
  name: ${CLUSTER_NAME}-db-url
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database-url
    app.kubernetes.io/part-of: ${APP_NAME}
    environment: ${ENVIRONMENT}
type: Opaque
data:
  # Database connection URL for in-cluster access
  # Format: postgresql://username:password@service-name.namespace:5432/database
  DATABASE_URL: ${DATABASE_URL_BASE64}
  # Individual connection components
  DB_HOST: ${DB_HOST_BASE64}
  DB_PORT: ${DB_PORT_BASE64}
  DB_NAME: ${DB_NAME_BASE64}
  DB_USER: ${DB_USER_BASE64}
  DB_PASSWORD: ${DB_PASSWORD_BASE64}
