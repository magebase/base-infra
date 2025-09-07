# Network Configuration Patch for Kourier Integration
# This patch updates the config-network ConfigMap to use Kourier as the ingress class

apiVersion: v1
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  # Kourier ingress class configuration
  ingress-class: "kourier.ingress.networking.knative.dev"

  # Domain template for Knative services
  domain-template: "{{.Name}}.{{.Namespace}}.{{.Domain}}"

  # Default external domain (should be configured in serving-default-domain.yaml.tpl)
  default-external-domain: "example.com"

  # Auto TLS setting (Disabled for initial setup)
  auto-tls: "Disabled"

  # HTTP protocol
  http-protocol: "http"

  # Cluster local domain TLS
  cluster-local-domain-tls: "Disabled"

  # System internal TLS
  system-internal-tls: "Disabled"

  # Rollout duration for networking changes
  rollout-duration: "0s"

  # Namespace wildcard certificate selector
  namespace-wildcard-cert-selector: ""

  # Label key for domain
  label-key-domain: "networking.knative.dev/disableWildcardCert"

  # Label key for wildcard cert
  label-key-wildcard-cert: "networking.knative.dev/wildcardCertificate"

  # Label key for visibility
  label-key-visibility: "networking.knative.dev/visibility"

  # Cluster local domain TLS
  cluster-local-domain-tls: "cluster-local"
