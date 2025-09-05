apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: site-db
  namespace: site
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
      destinationPath: "s3://${r2_bucket}/site/"
      endpointURL: "${r2_endpoint}"
      s3Credentials:
        accessKeyId:
          name: site-backup-secret
          key: access-key-id
        secretAccessKey:
          name: site-backup-secret
          key: secret-access-key
