apiVersion: v1
kind: ConfigMap
metadata:
  name: pod-security-config
  namespace: kube-system
data:
  pod-security-admission-config.yaml: |
    apiVersion: pod-security.admission.config.k8s.io/v1beta1
    kind: PodSecurityConfiguration
    defaults:
      enforce: "restricted"
      enforce-version: "v1.24"
      audit: "restricted"
      audit-version: "v1.24"
      warn: "restricted"
      warn-version: "v1.24"
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces: ["kube-system", "cert-manager", "argocd"]

# PodSecurityPolicy removed - using Pod Security Standards instead
# The Pod Security Standards configuration above provides the security controls
