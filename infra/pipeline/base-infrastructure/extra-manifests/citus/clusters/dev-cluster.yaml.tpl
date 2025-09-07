apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: citus-coordinator
  namespace: citus
  labels:
    app.kubernetes.io/name: citus-coordinator
    app.kubernetes.io/component: coordinator
    app.kubernetes.io/part-of: citus-cluster
spec:
  replicas: 3
  serviceName: citus-coordinator
  selector:
    matchLabels:
      app.kubernetes.io/name: citus-coordinator
  template:
    metadata:
      labels:
        app.kubernetes.io/name: citus-coordinator
        app.kubernetes.io/component: coordinator
        app.kubernetes.io/part-of: citus-cluster
    spec:
      serviceAccountName: citus-service-account
      containers:
      - name: citus-coordinator
        image: citusdata/citus:12.1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5432
          name: postgresql
        env:
        - name: POSTGRES_DB
          value: citus
        - name: POSTGRES_USER
          value: citus
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: citus-secrets
              key: password
        - name: PGDATA
          value: /var/lib/postgresql/data
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - citus
          initialDelaySeconds: 15
          periodSeconds: 10
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - citus
          initialDelaySeconds: 30
          periodSeconds: 10
      volumes:
      - name: postgres-data
        emptyDir: {}
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi

---
apiVersion: v1
kind: Service
metadata:
  name: citus-coordinator
  namespace: citus
  labels:
    app.kubernetes.io/name: citus-coordinator
    app.kubernetes.io/component: coordinator
    app.kubernetes.io/part-of: citus-cluster
spec:
  selector:
    app.kubernetes.io/name: citus-coordinator
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP

---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: citus-worker
  namespace: citus
  labels:
    app.kubernetes.io/name: citus-worker
    app.kubernetes.io/component: worker
    app.kubernetes.io/part-of: citus-cluster
spec:
  replicas: 0  # Start with zero replicas for cost optimization
  serviceName: citus-worker
  selector:
    matchLabels:
      app.kubernetes.io/name: citus-worker
  template:
    metadata:
      labels:
        app.kubernetes.io/name: citus-worker
        app.kubernetes.io/component: worker
        app.kubernetes.io/part-of: citus-cluster
    spec:
      serviceAccountName: citus-service-account
      containers:
      - name: citus-worker
        image: citusdata/citus:12.1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 5432
          name: postgresql
        env:
        - name: POSTGRES_DB
          value: citus
        - name: POSTGRES_USER
          value: citus
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: citus-secrets
              key: password
        - name: PGDATA
          value: /var/lib/postgresql/data
        volumeMounts:
        - name: postgres-data
          mountPath: /var/lib/postgresql/data
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - citus
          initialDelaySeconds: 15
          periodSeconds: 10
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - citus
          initialDelaySeconds: 30
          periodSeconds: 10
      volumes:
      - name: postgres-data
        emptyDir: {}
  volumeClaimTemplates:
  - metadata:
      name: postgres-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi

---
apiVersion: v1
kind: Service
metadata:
  name: citus-worker
  namespace: citus
  labels:
    app.kubernetes.io/name: citus-worker
    app.kubernetes.io/component: worker
    app.kubernetes.io/part-of: citus-cluster
spec:
  selector:
    app.kubernetes.io/name: citus-worker
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP

---
apiVersion: v1
kind: Secret
metadata:
  name: citus-secrets
  namespace: citus
  labels:
    app.kubernetes.io/part-of: citus-cluster
type: Opaque
data:
  password: $(echo -n "${CITUS_PASSWORD}" | base64)

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: citus-service-account
  namespace: citus
  labels:
    app.kubernetes.io/part-of: citus-cluster

---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: citus-role
  namespace: citus
rules:
- apiGroups: [""]
  resources: ["pods", "services", "endpoints"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: citus-role-binding
  namespace: citus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: citus-role
subjects:
- kind: ServiceAccount
  name: citus-service-account
