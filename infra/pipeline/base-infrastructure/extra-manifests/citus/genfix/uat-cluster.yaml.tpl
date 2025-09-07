apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: genfix-uat-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  cpu: "4"
  memory: "8Gi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: genfix-uat-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  postgresVersion: "15"
  postgresql.conf:
    shared_buffers: '2GB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '16'
    citus.max_cached_conns_per_worker: '8'
    wal_level: 'replica'
    max_wal_senders: '20'
    max_replication_slots: '20'
    checkpoint_completion_target: '0.9'
    wal_buffers: '16MB'
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: citus
  name: genfix-uat-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '1000'
        default_pool_size: '100'
        reserve_pool_size: '20'
        max_db_connections: '100'
        max_user_connections: '100'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: citus
  name: genfix-uat-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  type: 's3'
  s3:
    bucket: 'genfix-uat-citus-backups'
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
  name: genfix-uat-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 5
  sgInstanceProfile: 'genfix-uat-instance-profile'
  pods:
    persistentVolume:
      size: '200Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'genfix-uat-postgres-config'
    sgPoolingConfig: 'genfix-uat-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-uat-backup-storage'
      cronSchedule: '0 2 * * *'
      retention: 30
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '200Mi'
        maxDiskBandwidth: '200Mi'
        uploadDiskConcurrency: '8'
  distributedLogs:
    sgDistributedLogs: 'genfix-uat-distributed-logs'
  prometheusAutobind: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: genfix-uat-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: genfix
    environment: uat
spec:
  persistentVolume:
    size: '50Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
