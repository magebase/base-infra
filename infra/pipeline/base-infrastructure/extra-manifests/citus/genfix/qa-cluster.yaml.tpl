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
  cpu: "2"
  memory: "4Gi"
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
    shared_buffers: '1GB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '8'
    citus.max_cached_conns_per_worker: '4'
    wal_level: 'replica'
    max_wal_senders: '10'
    max_replication_slots: '10'
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
        max_client_conn: '500'
        default_pool_size: '50'
        reserve_pool_size: '10'
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
    bucket: 'genfix-qa-citus-backups'
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
  instances: 3
  sgInstanceProfile: 'genfix-qa-instance-profile'
  pods:
    persistentVolume:
      size: '100Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'genfix-qa-postgres-config'
    sgPoolingConfig: 'genfix-qa-pooling-config'
    backups:
    - sgObjectStorage: 'genfix-qa-backup-storage'
      cronSchedule: '0 3 * * *'
      retention: 30
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '100Mi'
        maxDiskBandwidth: '100Mi'
        uploadDiskConcurrency: '4'
  distributedLogs:
    sgDistributedLogs: 'genfix-qa-distributed-logs'
  prometheusAutobind: true
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
    size: '20Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
