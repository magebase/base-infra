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

# The config-network ConfigMap is defined in serving-core.yaml.tpl and patched by config-network-patch.yaml.tpl
# No additional ConfigMap definition needed here
