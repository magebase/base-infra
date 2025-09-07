apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: site-prod-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: site
    environment: prod
spec:
  cpu: "8"
  memory: "16Gi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: site-prod-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: site
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
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: citus
  name: site-prod-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: site
    environment: prod
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '2000'
        default_pool_size: '200'
        reserve_pool_size: '50'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: citus
  name: site-prod-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: site
    environment: prod
spec:
  type: 's3'
  s3:
    bucket: 'site-prod-citus-backups'
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
  name: site-prod-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: site
    environment: prod
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 7
  sgInstanceProfile: 'site-prod-instance-profile'
  pods:
    persistentVolume:
      size: '500Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'site-prod-postgres-config'
    sgPoolingConfig: 'site-prod-pooling-config'
    backups:
    - sgObjectStorage: 'site-prod-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 90
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '500Mi'
        maxDiskBandwidth: '500Mi'
        uploadDiskConcurrency: '16'
  distributedLogs:
    sgDistributedLogs: 'site-prod-distributed-logs'
  prometheusAutobind: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: site-prod-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: site
    environment: prod
spec:
  persistentVolume:
    size: '100Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
