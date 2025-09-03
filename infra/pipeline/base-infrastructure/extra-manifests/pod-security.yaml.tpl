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
---
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted-psp
  annotations:
    seccomp.security.alpha.kubernetes.io/allowedProfileNames: "docker/default,runtime/default"
    apparmor.security.beta.kubernetes.io/allowedProfileNames: "runtime/default"
    seccomp.security.alpha.kubernetes.io/defaultProfileName: "runtime/default"
    apparmor.security.beta.kubernetes.io/defaultProfileName: "runtime/default"
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - "configMap"
    - "downwardAPI"
    - "emptyDir"
    - "persistentVolumeClaim"
    - "secret"
    - "projected"
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: "MustRunAsNonRoot"
  seLinux:
    rule: "RunAsAny"
  supplementalGroups:
    rule: "MustRunAs"
    ranges:
      - min: 1
        max: 65535
  fsGroup:
    rule: "MustRunAs"
    ranges:
      - min: 1
        max: 65535
  readOnlyRootFilesystem: true
