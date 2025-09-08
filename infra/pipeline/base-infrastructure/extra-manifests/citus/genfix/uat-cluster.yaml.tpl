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
  cpu: "250m"
  memory: "512Mi"
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
        max_client_conn: '50'
        default_pool_size: '5'
        reserve_pool_size: '2'
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
    bucket: 'stackgres'
    region: 'k8s'
    enablePathStyleAddressing: true
    endpoint: '{OBJECT_STORAGE_BACKUP_ENDPOINT}'
    awsCredentials:
      secretKeySelectors:
        accessKeyId:
          key: accesskey
          name: my-cluster-minio
        secretAccessKey:
          key: secretkey
          name: my-cluster-minio
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
    size: '5Gi'
    storageClass: 'local-path'
  postgres:
    version: '15'
