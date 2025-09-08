apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: genfix-qa-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: genfix
    environment: qa
spec:
  cpu: "250m"
  memory: "512Mi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: genfix-qa-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: genfix
    environment: qa
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
  namespace: citus
  name: genfix-qa-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: genfix
    environment: qa
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
  namespace: citus
  name: genfix-qa-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: genfix
    environment: qa
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
          name: citus-r2-credentials
        secretAccessKey:
          key: secretKey
          name: citus-r2-credentials
---
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  namespace: citus
  name: genfix-qa-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
    environment: qa
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 1
  sgInstanceProfile: 'genfix-qa-instance-profile'
  pods:
    persistentVolume:
      size: '10Gi'
      storageClass: 'local-path'
  autoscaling:
    horizontal:
      cooldownPeriod: 300
      pollingInterval: 30
      minInstances: 0
      maxInstances: 3
      replicasConnectionsUsageTarget: '0.8'
      replicasConnectionsUsageMetricType: 'AverageValue'
  configurations:
    sgPostgresConfig: 'genfix-qa-postgres-config'
    sgPoolingConfig: 'genfix-qa-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-qa-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 14
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '50Mi'
        maxDiskBandwidth: '50Mi'
        uploadDiskConcurrency: '2'
  distributedLogs:
    sgDistributedLogs: 'genfix-qa-distributed-logs'
  prometheusAutobind: true
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
    disablePatroniResourceRequirements: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: genfix-qa-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: genfix
    environment: qa
spec:
  persistentVolume:
    size: '5Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
---
apiVersion: v1
kind: Secret
metadata:
  namespace: citus
  name: genfix-qa-cluster-db-url
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database-url
    app.kubernetes.io/part-of: genfix
    environment: qa
type: Opaque
data:
  # Database connection URL for in-cluster access
  DATABASE_URL: ${GENFIX_QA_DATABASE_URL}
  # Individual connection components
  DB_HOST: ${DB_HOST_BASE64}
  DB_PORT: ${DB_PORT_BASE64}
  DB_NAME: ${DB_NAME_GENFIX_BASE64}
  DB_USER: ${DB_USER_BASE64}
  DB_PASSWORD: ${DB_PASSWORD_BASE64}
