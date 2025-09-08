apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: database
  name: site-dev-instance-profile
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: site
    environment: dev
spec:
  cpu: "250m"
  memory: "512Mi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: database
  name: site-dev-postgres-config
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: site
    environment: dev
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
  name: site-dev-pooling-config
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: site
    environment: dev
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
  name: site-dev-backup-storage
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: site
    environment: dev
spec:
  type: 's3'
  s3:
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
apiVersion: stackgres.io/v1alpha1
kind: SGShardedCluster
metadata:
  namespace: database
  name: site-dev-cluster
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: site
    environment: dev
spec:
  type: citus
  database: site
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  coordinator:
    instances: 1
    sgInstanceProfile: 'site-dev-instance-profile'
    pods:
      persistentVolume:
        size: '10Gi'
        storageClass: 'local-path'
    configurations:
      sgPostgresConfig: 'site-dev-postgres-config'
      sgPoolingConfig: 'site-dev-pooling-config'
  shards:
    clusters: 1
    instancesPerCluster: 1
    sgInstanceProfile: 'site-dev-instance-profile'
    pods:
      persistentVolume:
        size: '10Gi'
        storageClass: 'local-path'
    configurations:
      sgPostgresConfig: 'site-dev-postgres-config'
      sgPoolingConfig: 'site-dev-pooling-config'
  configurations:
    backups:
    - sgObjectStorage: 'site-dev-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 7
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '50Mi'
        maxDiskBandwidth: '50Mi'
        uploadDiskConcurrency: '2'
    observability:
      prometheusAutobind: true
  distributedLogs:
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
    disablePatroniResourceRequirements: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: database
  name: site-dev-distributed-logs
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: site
    environment: dev
spec:
  persistentVolume:
    size: '5Gi'
    storageClass: 'local-path'
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: site-dev-database-secret
  namespace: database
spec:
  refreshInterval: 15s
  secretStoreRef:
    name: site-secret-store
    kind: SecretStore
  target:
    name: site-dev-ssm-database-url
    creationPolicy: Owner
  data:
  - secretKey: DATABASE_URL
    remoteRef:
      key: /site/dev/database/url
---
apiVersion: v1
kind: Secret
metadata:
  namespace: database
  name: site-dev-db-url
  labels:
    app.kubernetes.io/name: database-cluster
    app.kubernetes.io/component: database-url
    app.kubernetes.io/part-of: site
    environment: dev
type: Opaque
data:
  # Database connection URL for in-cluster access
  # Format: postgresql://username:password@service-name.database:5432/database
  DATABASE_URL: placeholder
