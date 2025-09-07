apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: genfix-dev-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  cpu: "500m"
  memory: "1Gi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: genfix-dev-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  postgresVersion: "15"
  postgresql.conf:
    shared_buffers: '256MB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '4'
    citus.max_cached_conns_per_worker: '2'
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: citus
  name: genfix-dev-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '200'
        default_pool_size: '20'
        reserve_pool_size: '5'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: citus
  name: genfix-dev-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  type: 's3'
  s3:
    bucket: 'genfix-dev-citus-backups'
    region: 'auto'
    endpoint: 'https://<account-id>.r2.cloudflarestorage.com'
    awsCredentials:
      secretKeySelectors:
        accessKeyId: {name: 'citus-r2-credentials', key: 'accessKey'}
        secretAccessKey: {name: 'citus-r2-credentials', key: 'secretKey'}
---
apiVersion: stackgres.io/v1
kind: SGCluster
metadata:
  namespace: citus
  name: genfix-dev-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 3
  sgInstanceProfile: 'genfix-dev-instance-profile'
  pods:
    persistentVolume:
      size: '50Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'genfix-dev-postgres-config'
    sgPoolingConfig: 'genfix-dev-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-dev-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 7
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '50Mi'
        maxDiskBandwidth: '50Mi'
        uploadDiskConcurrency: '2'
  distributedLogs:
    sgDistributedLogs: 'genfix-dev-distributed-logs'
  prometheusAutobind: true
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
    disablePatroniResourceRequirements: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: genfix-dev-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: genfix
    environment: dev
spec:
  persistentVolume:
    size: '10Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
