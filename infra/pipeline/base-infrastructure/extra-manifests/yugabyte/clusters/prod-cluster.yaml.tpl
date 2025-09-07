apiVersion: v1
kind: Namespace
metadata:
  name: yb
  labels:
    name: yb
---
apiVersion: v1
kind: Secret
metadata:
  name: yugabyte-tls-certs
  namespace: yb
type: Opaque
data:
  # Base64 encoded TLS certificates will be populated during deployment
  ca.crt: ""
  tls.crt: ""
  tls.key: ""
---
apiVersion: v1
kind: Secret
metadata:
  name: yugabyte-db-credentials
  namespace: yb
type: Opaque
data:
  # Base64 encoded database credentials
  username: "YWRtaW4="  # admin
  password: ""  # Will be populated during deployment
---
apiVersion: v1
kind: Secret
metadata:
  name: yugabyte-r2-credentials
  namespace: yb
type: Opaque
data:
  # Cloudflare R2 credentials for backups
  accessKey: ""  # Base64 encoded R2 access key
  secretKey: ""  # Base64 encoded R2 secret key
---
apiVersion: yugabyte.com/v1alpha1
kind: YBCluster
metadata:
  name: prod-cluster
  namespace: yb
  labels:
    app.kubernetes.io/name: yugabyte
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: prod
spec:
  # Number of master and tserver pods (single master node)
  numNodes: 1

  # YugabyteDB version
  version: "2.20.5.0"

  # Master configuration
  master:
    # Master pod configuration
    masterPodSpec:
      containers:
      - name: yb-master
        resources:
          requests:
            cpu: 4
            memory: 8Gi
          limits:
            cpu: 8
            memory: 16Gi
        volumeMounts:
        - name: datadir
          mountPath: /mnt/disk0
      volumes:
      - name: datadir
        persistentVolumeClaim:
          claimName: yb-master-pvc

    # Master service configuration
    masterServiceSpec:
      type: ClusterIP
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"

  # TServer configuration
  tserver:
    # TServer pod configuration
    tserverPodSpec:
      containers:
      - name: yb-tserver
        resources:
          requests:
            cpu: 4
            memory: 8Gi
          limits:
            cpu: 8
            memory: 16Gi
        volumeMounts:
        - name: datadir
          mountPath: /mnt/disk0
      volumes:
      - name: datadir
        persistentVolumeClaim:
          claimName: yb-tserver-pvc

    # TServer service configuration
    tserverServiceSpec:
      type: ClusterIP
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"

  # Storage configuration
  storage:
    # Master storage
    master:
      storageClass: "local-path"
      size: 500Gi

    # TServer storage
    tserver:
      storageClass: "local-path"
      size: 1Ti

  # Replication factor
  replicationFactor: 1

  # Enable YSQL API
  enableYSQL: true

  # Enable YCQL API
  enableYCQL: true

  # TLS configuration
  tls:
    enabled: true
    certManager:
      clusterIssuer: letsencrypt-prod
      dnsNames:
      - prod-cluster.yb.svc.cluster.local

  # Monitoring configuration
  prometheus:
    enabled: true
    scrapeInterval: 30s

  # Backup configuration
  backup:
    enabled: true
    schedule: "0 1 * * *"
    retention: "90d"
    storage:
      type: s3
      bucket: prod-yugabyte-backups
      region: auto
      endpoint: https://<account-id>.r2.cloudflarestorage.com
      credentialsSecret: yugabyte-r2-credentials
