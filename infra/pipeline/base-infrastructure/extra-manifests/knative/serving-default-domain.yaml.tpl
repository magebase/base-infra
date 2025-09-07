# Default Domain Configuration for Knative Serving
# Template for: https://github.com/knative/serving/releases/download/knative-v1.18.1/serving-default-domain.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: config-domain
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  # Default domain for Knative services
  # Replace with your actual domain
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

    # Default domain template
    # Format: {{.Name}}.{{.Namespace}}.{{.Domain}}
    # Example: hello.default.example.com
    example.com: ""

    # Magic DNS (sslip.io or nip.io)
    # Replace with your actual domain or use magic DNS
    # sslip.io format: <service-name>.<namespace>.<external-ip>.sslip.io
    # nip.io format: <service-name>.<namespace>.<external-ip>.nip.io

    # For local development with magic DNS:
    # sslip.io: ""
    # nip.io: ""

    # For production with custom domain:
    # yourdomain.com: ""

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: config-network
  namespace: knative-serving
  labels:
    app.kubernetes.io/version: "1.18.1"
data:
  # Network configuration for default domain
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

    # The domain template for Knative services.
    domain-template: "{{.Name}}.{{.Namespace}}.{{.Domain}}"

    # The default domain for Knative services.
    # This should match one of the domains configured in config-domain
    default-external-domain: "example.com"

    # The auto TLS setting.
    auto-tls: "Disabled"

    # The HTTP protocol for Knative services.
    http-protocol: "http"

    # The cluster local domain TLS setting.
    cluster-local-domain-tls: "Disabled"

    # The system internal TLS setting.
    system-internal-tls: "Disabled"

    # The rollout duration for networking changes.
    rollout-duration: "0s"

    # The namespace wildcard certificate name.
    namespace-wildcard-cert-selector: ""

    # The label key for domain.
    label-key-domain: "networking.knative.dev/disableWildcardCert"

    # The label key for wildcard cert.
    label-key-wildcard-cert: "networking.knative.dev/wildcardCertificate"

    # The label key for visibility.
    label-key-visibility: "networking.knative.dev/visibility"

    # The visibility for cluster local services.
    cluster-local-domain-tls: "cluster-local"
