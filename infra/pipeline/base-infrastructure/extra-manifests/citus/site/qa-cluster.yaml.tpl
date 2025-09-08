apiVersion: stackgres.io/v1
kind: SGInstanceProfile
metadata:
  namespace: citus
  name: site-qa-instance-profile
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: instance-profile
    app.kubernetes.io/part-of: site
    environment: qa
spec:
  cpu: "250m"
  memory: "512Mi"
---
apiVersion: stackgres.io/v1
kind: SGPostgresConfig
metadata:
  namespace: citus
  name: site-qa-postgres-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: postgres-config
    app.kubernetes.io/part-of: site
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
  name: site-qa-pooling-config
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: pooling-config
    app.kubernetes.io/part-of: site
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
  name: site-qa-backup-storage
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: backup-storage
    app.kubernetes.io/part-of: site
    environment: qa
spec:
  type: 's3'
  s3:
    bucket: 'site-qa-citus-backups'
    region: 'auto'
    endpoint: 'https://<account-id>.r2.cloudflarestorage.com'
    awsCredentials:
      secretKeySelectors:
        accessKeyId: {name: 'citus-r2-credentials', key: 'accessKey'}
        secretAccessKey: {name: 'citus-r2-credentials', key: 'secretKey'}
---
apiVersion: stackgres.io/v1alpha1
kind: SGShardedCluster
metadata:
  namespace: citus
  name: site-qa-cluster
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: site
    environment: qa
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
    sgInstanceProfile: 'site-qa-instance-profile'
    pods:
      persistentVolume:
        size: '10Gi'
        storageClass: 'local-path'
    configurations:
      sgPostgresConfig: 'site-qa-postgres-config'
      sgPoolingConfig: 'site-qa-pooling-config'
  shards:
    clusters: 1
    instancesPerCluster: 1
    sgInstanceProfile: 'site-qa-instance-profile'
    pods:
      persistentVolume:
        size: '10Gi'
        storageClass: 'local-path'
    configurations:
      sgPostgresConfig: 'site-qa-postgres-config'
      sgPoolingConfig: 'site-qa-pooling-config'
  configurations:
    backups:
    - sgObjectStorage: 'site-qa-backup-storage'
      cronSchedule: '0 4 * * *'
      retention: 14
      compression: 'gzip'
      performance:
        maxNetworkBandwidth: '50Mi'
        maxDiskBandwidth: '50Mi'
        uploadDiskConcurrency: '2'
  distributedLogs:
    sgDistributedLogs: 'site-qa-distributed-logs'
  prometheusAutobind: true
  nonProductionOptions:
    disableClusterPodAntiAffinity: true
    disablePatroniResourceRequirements: true
---
apiVersion: stackgres.io/v1
kind: SGDistributedLogs
metadata:
  namespace: citus
  name: site-qa-distributed-logs
  labels:
    app.kubernetes.io/name: citus-cluster
    app.kubernetes.io/component: distributed-logs
    app.kubernetes.io/part-of: site
    environment: qa
spec:
  persistentVolume:
    size: '5Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
