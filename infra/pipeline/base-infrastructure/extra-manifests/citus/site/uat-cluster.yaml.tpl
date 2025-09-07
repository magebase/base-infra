apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: site-uat-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  cpu: "2"
  memory: "4Gi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: site-uat-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  postgresVersion: "15"
  postgresql.conf:
    shared_buffers: '1GB'
    random_page_cost: '1.5'
    password_encryption: 'scram-sha-256'
    log_checkpoints: 'on'
    citus.max_worker_processes: '16'
    citus.max_cached_conns_per_worker: '8'
---
apiVersion: stackgres.io/v1
kind: SGPoolingConfig
metadata:
  namespace: citus
  name: site-uat-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  pgBouncer:
    pgbouncer.ini:
      pgbouncer:
        pool_mode: transaction
        max_client_conn: '1000'
        default_pool_size: '100'
        reserve_pool_size: '20'
---
apiVersion: stackgres.io/v1beta1
kind: SGObjectStorage
metadata:
  namespace: citus
  name: site-uat-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  type: 's3'
  s3:
    bucket: 'site-uat-citus-backups'
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
  name: site-uat-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  postgres:
    version: '15'
    extensions:
    - name: citus
      version: '12.1'
  instances: 5
  sgInstanceProfile: 'site-uat-instance-profile'
  pods:
    persistentVolume:
      size: '200Gi'
      storageClass: 'local-path'
  configurations:
    sgPostgresConfig: 'site-uat-postgres-config'
    sgPoolingConfig: 'site-uat-pooling-config'
    backups:
    - sgObjectStorage: 'site-uat-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 30
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '200Mi'
        maxDiskBandwidth: '200Mi'
        uploadDiskConcurrency: '8'
  distributedLogs:
    sgDistributedLogs: 'site-uat-distributed-logs'
  prometheusAutobind: true
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
    disablePatroniResourceRequirements: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: site-uat-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: site
    environment: uat
spec:
  persistentVolume:
    size: '50Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
