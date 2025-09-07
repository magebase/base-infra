apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: genfix-prod-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  cpu: "8"
  memory: "16Gi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: genfix-prod-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  postgresVersion: "15"
  postgresql.conf:
    shared_buffers: '4GB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '32'
    citus.max_cached_conns_per_worker: '16'
    wal_level: 'replica'
    max_wal_senders: '32'
    max_replication_slots: '32'
    checkpoint_completion_target: '0.9'
    wal_buffers: '32MB'
    work_mem: '64MB'
    maintenance_work_mem: '512MB'
    checkpoint_segments: '32'
    autovacuum_max_workers: '6'
    autovacuum_naptime: '20s'
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: citus
  name: genfix-prod-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '2000'
        default_pool_size: '200'
        reserve_pool_size: '50'
        max_db_connections: '200'
        max_user_connections: '200'
        server_idle_timeout: '300'
        server_lifetime: '3600'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: citus
  name: genfix-prod-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  type: 's3'
  s3:
    bucket: 'genfix-prod-citus-backups'
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
  name: genfix-prod-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 7
  sgInstanceProfile: 'genfix-prod-instance-profile'
  pods:
    persistentVolume:
      size: '500Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'genfix-prod-postgres-config'
    sgPoolingConfig: 'genfix-prod-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-prod-backup-storage'
      cronSchedule: '0 1 * * *'
      retention: 90
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '500Mi'
        maxDiskBandwidth: '500Mi'
        uploadDiskConcurrency: '16'
      fastVolumeSnapshot: true
  distributedLogs:
    sgDistributedLogs: 'genfix-prod-distributed-logs'
  prometheusAutobind: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: genfix-prod-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: genfix
    environment: prod
spec:
  persistentVolume:
    size: '100Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
