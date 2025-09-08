apiVersion: apps/v1
kind: Deployment
metadata:
  name: stackgres-restapi
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-restapi
    app.kubernetes.io/component: restapi
    app.kubernetes.io/part-of: citus
    group: stackgres.io
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: stackgres-restapi
      group: stackgres.io
  template:
    metadata:
      labels:
        app.kubernetes.io/name: stackgres-restapi
        app.kubernetes.io/component: restapi
        app.kubernetes.io/part-of: citus
        group: stackgres.io
    spec:
      serviceAccountName: stackgres-operator
      containers:
      - name: restapi
        image: stackgres/restapi:1.9.0
        imagePullPolicy: IfNotPresent
        env:
        - name: STACKGRES_RESTAPI_HOST
          value: "0.0.0.0"
        - name: STACKGRES_RESTAPI_PORT
          value: "443"
        - name: STACKGRES_RESTAPI_SCHEME
          value: "https"
        ports:
        - containerPort: 443
          name: restapi
          protocol: TCP
        volumeMounts:
        - name: restapi-cert
          mountPath: /tmp/k8s-webhook-server/serving-certs
          readOnly: true
        livenessProbe:
          httpGet:
            path: /stackgres/health
            port: 443
            scheme: HTTPS
          initialDelaySeconds: 15
          periodSeconds: 20
        readinessProbe:
          httpGet:
            path: /stackgres/health
            port: 443
            scheme: HTTPS
          initialDelaySeconds: 5
          periodSeconds: 10
        resources:
          requests:
            cpu: 50m
            memory: 64Mi
          limits:
            cpu: 200m
            memory: 256Mi
      volumes:
      - name: restapi-cert
        secret:
          defaultMode: 420
          secretName: stackgres-restapi-certs
---
apiVersion: v1
kind: Service
metadata:
  name: stackgres-restapi
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-restapi
    app.kubernetes.io/component: restapi
    app.kubernetes.io/part-of: citus
    group: stackgres.io
spec:
  ports:
  - name: restapi
    port: 443
    protocol: TCP
    targetPort: 443
  selector:
    app.kubernetes.io/name: stackgres-restapi
    group: stackgres.io
  type: ClusterIP
