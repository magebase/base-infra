apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: database
  name: genfix-uat-instance-profile
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  cpu: "250m"
  memory: "512Mi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: database
  name: genfix-uat-postgres-config
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  postgresVersion: "15"
  postgresql.conf:
    shared_buffers: '128MB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '2'
    citus.max_cached_conns_per_worker: '1'
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: database
  name: genfix-uat-pooling-config
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '50'
        default_pool_size: '5'
        reserve_pool_size: '2'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: database
  name: genfix-uat-backup-storage
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  type: 's3Compatible'
  s3Compatible:
    bucket: '${R2_BUCKET}'
    region: 'k8s'
    enablePathStyleAddressing: true
    endpoint: '${R2_ENDPOINT}'
    awsCredentials:
      secretKeySelectors:
        accessKeyId:
          key: accessKey
          name: database-r2-credentials
        secretAccessKey:
          key: secretKey
          name: database-r2-credentials
---
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  namespace: database
  name: genfix-uat-cluster
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 1
  sgInstanceProfile: 'genfix-uat-instance-profile'
  pods:
    persistentVolume:
      size: '10Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'genfix-uat-postgres-config'
    sgPoolingConfig: 'genfix-uat-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-uat-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 30
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '50Mi'
        maxDiskBandwidth: '50Mi'
        uploadDiskConcurrency: '2'
    observability:
      prometheusAutobind: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: database
  name: genfix-uat-distributed-logs
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  persistentVolume:
    size: '5Gi'
    storageClass: 'local-path'
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: genfix-uat-database-secret
  namespace: database
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: genfix-secret-store
    kind: SecretStore
  target:
    name: genfix-uat-ssm-database-url
    creationPolicy: Owner
  data:
  - secretKey: DATABASE_URL
    remoteRef:
      key: /genfix/uat/genfix/database/url
---
apiVersion: v1
kind: Secret
metadata:
  namespace: database
  name: genfix-uat-db-url
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: database-url
    app.kubernetes.io/part-of: genfix
    environment: uat
type: Opaque
data:
  # Database connection URL for in-cluster access
  # Format: postgresql://username:password@service-name.database:5432/database
  DATABASE_URL: cGxhY2Vob2xkZXI=
