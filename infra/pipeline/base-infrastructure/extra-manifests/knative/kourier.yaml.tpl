# Kourier Networking Layer
# Template for: https://github.com/knative/net-kourier/releases/download/knative-v1.18.1/kourier.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: 3scale-kourier-gateway
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: 3scale-kourier-gateway
  labels:
    app.kubernetes.io/version: "1.18.1"
rules:
- apiGroups: [""]
  resources: ["pods", "endpoints", "services"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses/status"]
  verbs: ["get", "update", "patch"]
- apiGroups: ["networking.internal.knative.dev"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.internal.knative.dev"]
  resources: ["ingresses/status"]
  verbs: ["get", "update", "patch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: 3scale-kourier-gateway
  labels:
    app.kubernetes.io/version: "1.18.1"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: 3scale-kourier-gateway
subjects:
- kind: ServiceAccount
  name: 3scale-kourier-gateway
  namespace: kourier-system

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kourier-gateway
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  envoy.yaml: |
    static_resources:
      listeners:
      - name: main
        address:
          socket_address:
            address: 0.0.0.0
            port_value: 8080
        filter_chains:
        - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              stat_prefix: ingress_http
              access_log:
              - name: envoy.access_loggers.file
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog
                  path: /dev/stdout
                  log_format:
                    text_format: "[%START_TIME%] \"%REQ(:METHOD)% %REQ(X-ENVOY-ORIGINAL-PATH?:PATH)% %PROTOCOL%\" %RESPONSE_CODE% %RESPONSE_FLAGS% %BYTES_RECEIVED% %BYTES_SENT% %DURATION% %RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)% \"%REQ(X-REQUEST-ID)%\" \"%REQ(:AUTHORITY)%\" \"%UPSTREAM_HOST%\" %UPSTREAM_CLUSTER% %UPSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_LOCAL_ADDRESS% %DOWNSTREAM_REMOTE_ADDRESS% %REQUESTED_SERVER_NAME% %ROUTE_NAME%\n"
              http_filters:
              - name: envoy.filters.http.router
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
              route_config:
                name: local_route
                virtual_hosts:
                - name: local
                  domains: ["*"]
                  routes:
                  - match:
                      prefix: "/"
                    route:
                      cluster: local
      clusters:
      - name: local
        type: LOGICAL_DNS
        dns_lookup_family: V4_ONLY
        load_assignment:
          cluster_name: local
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: 127.0.0.1
                    port_value: 8081

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 3scale-kourier-gateway
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: 3scale-kourier-gateway
  template:
    metadata:
      labels:
        app: 3scale-kourier-gateway
        app.kubernetes.io/version: "1.18.1"
    spec:
      serviceAccountName: 3scale-kourier-gateway
      containers:
      - name: kourier-gateway
        image: gcr.io/knative-releases/knative.dev/net-kourier/cmd/kourier@sha256:placeholder
        ports:
        - containerPort: 8080
          name: http
        - containerPort: 8081
          name: http2
        - containerPort: 19000
          name: admin
        env:
        - name: KOURIER_GATEWAY_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: KOURIER_GATEWAY_CONFIG
          value: /tmp/config/envoy.yaml
        volumeMounts:
        - name: config-volume
          mountPath: /tmp/config
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
          limits:
            cpu: 200m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          capabilities:
            drop:
            - ALL
        readinessProbe:
          httpGet:
            port: 19000
            path: /ready
          periodSeconds: 10
          timeoutSeconds: 5
        livenessProbe:
          httpGet:
            port: 19000
            path: /ready
          periodSeconds: 10
          timeoutSeconds: 5
      volumes:
      - name: config-volume
        configMap:
          name: kourier-gateway

---
apiVersion: v1
kind: Service
metadata:
  name: kourier
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"
spec:
  selector:
    app: 3scale-kourier-gateway
  ports:
  - name: http2
    port: 80
    targetPort: 8080
  - name: https
    port: 443
    targetPort: 8443

---
apiVersion: v1
kind: Service
metadata:
  name: kourier-internal
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"
spec:
  selector:
    app: 3scale-kourier-gateway
  ports:
  - name: http2
    port: 80
    targetPort: 8081

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kourier-ingress
  namespace: kourier-system
  labels:
    app.kubernetes.io/version: "1.18.1"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kourier
            port:
              number: 80

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-kourier
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  _example: |
    ################################
    #                              #
    #    EXAMPLE CONFIGURATION     #
    #                              #
    ################################

    # This block is not actually functional configuration,
    # but serves to illustrate the available configuration
    # options and document them in a way that is accessible
    # to users that `kubectl edit` this config map.
    #
    # These sample configuration options may be copied out of
    # this example block and unindented to be in the `data` block
    # to actually change the configuration.

    # The ingress class to use for Knative services.
    ingress-class: "kourier.ingress.networking.knative.dev"

    # The cluster certificate for TLS.
    cluster-cert-secret: ""

    # The system namespace.
    system-namespace: "knative-serving"

    # The Kourier gateway namespace.
    kourier-namespace: "kourier-system"

    # Enable debug logging.
    enable-service-access-logging: "false"

    # The maximum number of concurrent connections.
    max-connections: "1024"

    # The maximum number of concurrent streams.
    max-pending-requests: "1024"

    # The maximum number of requests per connection.
    max-requests-per-connection: "256"

    # The idle timeout for connections.
    idle-timeout: "300s"

    # The request timeout.
    request-timeout: "300s"

    # The response timeout.
    response-timeout: "300s"

    # The connect timeout.
    connect-timeout: "5s"

    # The cluster local domain.
    cluster-local-domain-tls: "cluster-local"

    # The external domain.
    external-domain-tls: ""

    # The auto TLS setting.
    auto-tls: "Disabled"

    # The HTTP protocol.
    http-protocol: "http"

    # The rollout duration.
    rollout-duration: "0s"

    # The namespace wildcard certificate name.
    namespace-wildcard-cert-selector: ""

    # The label key for domain.
    label-key-domain: "networking.knative.dev/disableWildcardCert"

    # The label key for wildcard cert.
    label-key-wildcard-cert: "networking.knative.dev/wildcardCertificate"

    # The label key for visibility.
    label-key-visibility: "networking.knative.dev/visibility"
