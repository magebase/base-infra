apiVersion: apps/v1
kind: Deployment
metadata:
  name: stackgres-operator
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
    group: stackgres.io
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: stackgres-operator
      group: stackgres.io
  template:
    metadata:
      labels:
        app.kubernetes.io/name: stackgres-operator
        app.kubernetes.io/component: operator
        app.kubernetes.io/part-of: citus
        group: stackgres.io
    spec:
      serviceAccountName: stackgres-operator
      containers:
      - name: operator
        image: stackgres/operator:1.9.0
        imagePullPolicy: IfNotPresent
        env:
        - name: STACKGRES_OPERATOR_IMAGE_NAME
          value: stackgres/operator:1.9.0
        - name: STACKGRES_OPERATOR_IMAGE_PULL_POLICY
          value: IfNotPresent
        - name: STACKGRES_RESTAPI_IMAGE_NAME
          value: stackgres/restapi:1.9.0
        - name: STACKGRES_RESTAPI_IMAGE_PULL_POLICY
          value: IfNotPresent
        - name: STACKGRES_ADMINUI_IMAGE_NAME
          value: stackgres/admin-ui:1.9.0
        - name: STACKGRES_ADMINUI_IMAGE_PULL_POLICY
          value: IfNotPresent
        - name: STACKGRES_JOBS_IMAGE_NAME
          value: stackgres/jobs:1.9.0
        - name: STACKGRES_JOBS_IMAGE_PULL_POLICY
          value: IfNotPresent
        - name: STACKGRES_CLUSTER_CONTROLLER_IMAGE_NAME
          value: stackgres/cluster-controller:1.9.0
        - name: STACKGRES_CLUSTER_CONTROLLER_IMAGE_PULL_POLICY
          value: IfNotPresent
        - name: STACKGRES_DISTRIBUTEDLOGS_CONTROLLER_IMAGE_NAME
          value: stackgres/distributedlogs-controller:1.9.0
        - name: STACKGRES_DISTRIBUTEDLOGS_CONTROLLER_IMAGE_PULL_POLICY
          value: IfNotPresent
        # Citus extension configuration
        - name: STACKGRES_EXTENSIONS_REPOSITORY_URLS
          value: https://extensions.stackgres.io/postgres/repository
        - name: STACKGRES_EXTENSIONS_CACHE_PRELOADED_EXTENSIONS
          value: citus
        # Monitoring configuration
        - name: STACKGRES_MONITOR_PROMETHEUS_AUTOBIND
          value: "true"
        - name: STACKGRES_GRAFANA_AUTOEMBED
          value: "true"
        - name: STACKGRES_GRAFANA_WEBHOST
          value: prometheus-grafana.monitoring
        - name: STACKGRES_GRAFANA_SECRET_NAMESPACE
          value: monitoring
        - name: STACKGRES_GRAFANA_SECRET_NAME
          value: prometheus-grafana
        - name: STACKGRES_GRAFANA_SECRET_USER_KEY
          value: admin-user
        - name: STACKGRES_GRAFANA_SECRET_PASSWORD_KEY
          value: admin-password
        ports:
        - containerPort: 9443
          name: webhook-server
          protocol: TCP
        volumeMounts:
        - name: webhook-cert
          mountPath: /tmp/k8s-webhook-server/serving-certs
          readOnly: true
        livenessProbe:
          httpGet:
            path: /healthz
            port: 9443
            scheme: HTTPS
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /readyz
            port: 9443
            scheme: HTTPS
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      volumes:
      - name: webhook-cert
        secret:
          defaultMode: 420
          secretName: stackgres-operator-certs
---
apiVersion: v1
kind: Service
metadata:
  name: stackgres-operator
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
    group: stackgres.io
spec:
  ports:
  - name: webhook
    port: 443
    protocol: TCP
    targetPort: 9443
  selector:
    app.kubernetes.io/name: stackgres-operator
    group: stackgres.io
  type: ClusterIP
