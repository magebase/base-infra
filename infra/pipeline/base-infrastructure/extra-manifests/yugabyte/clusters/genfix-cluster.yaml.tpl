apiVersion: v1
kind: Namespace
metadata:
  name: yb-demo
  labels:
    name: yb-demo
---
apiVersion: v1
kind: Secret
metadata:
  name: yugabyte-tls-certs
  namespace: yb-demo
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
  namespace: yb-demo
type: Opaque
data:
  # Base64 encoded database credentials
  username: "YWRtaW4="  # admin
  password: ""  # Will be populated during deployment
---
apiVersion: yugabyte.com/v1alpha1
kind: YBCluster
metadata:
  name: genfix-cluster
  namespace: yb-demo
  labels:
    app.kubernetes.io/name: yugabyte
    app.kubernetes.io/component: database
    app.kubernetes.io/part-of: genfix
spec:
  # Number of master and tserver pods
  numNodes: 3

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
            cpu: 2
            memory: 4Gi
          limits:
            cpu: 4
            memory: 8Gi
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
            cpu: 2
            memory: 4Gi
          limits:
            cpu: 4
            memory: 8Gi
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
      size: 100Gi

    # TServer storage
    tserver:
      storageClass: "local-path"
      size: 200Gi

  # Replication factor
  replicationFactor: 3

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
      - genfix-cluster.yb-demo.svc.cluster.local

  # Monitoring configuration
  prometheus:
    enabled: true
    scrapeInterval: 30s

  # Backup configuration
  backup:
    enabled: true
    schedule: "0 2 * * *"
    retention: "30d"
    storage:
      type: s3
      bucket: genfix-yugabyte-backups
      region: us-east-1
