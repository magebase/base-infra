apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: genfix-db
  namespace: genfix
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql:15.6
  primaryUpdateStrategy: unsupervised
  storage:
    size: 1Gi
    storageClass: local-path
  postgresql:
    parameters:
      max_connections: "50"
      shared_buffers: "32MB"
      work_mem: "4MB"
      maintenance_work_mem: "32MB"
      effective_cache_size: "128MB"
  resources:
    requests:
      memory: "128Mi"
      cpu: "100m"
    limits:
      memory: "256Mi"
      cpu: "200m"
  monitoring:
    enablePodMonitor: true
  backup:
    retentionPolicy: "30d"
    barmanObjectStore:
      destinationPath: "s3://genfix-backups/"
      endpointURL: "https://s3.amazonaws.com"
      s3Credentials:
        accessKeyId:
          name: genfix-backup-secret
          key: access-key-id
        secretAccessKey:
          name: genfix-backup-secret
          key: secret-access-key
