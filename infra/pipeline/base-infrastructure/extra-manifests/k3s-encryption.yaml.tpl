apiVersion: v1
kind: Secret
metadata:
  name: k3s-encryption-config
  namespace: kube-system
  labels:
    environment: ${environment}
    app.kubernetes.io/name: k3s
    app.kubernetes.io/component: encryption-config
type: Opaque
stringData:
  encryption-config.yaml: |
    apiVersion: apiserver.config.k8s.io/v1
    kind: EncryptionConfiguration
    resources:
    - resources:
      - secrets
      providers:
      - aescbc:
          keys:
          - name: key1
            secret: ${encryption_key}
      - identity: {}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: k3s-etcd-encryption
  namespace: kube-system
data:
  etcd-encryption.yaml: |
    apiVersion: apiserver.config.k8s.io/v1
    kind: EncryptionConfiguration
    resources:
    - resources:
      - configmaps
      - secrets
      - events
      providers:
      - aescbc:
          keys:
          - name: key1
            secret: ${encryption_key}
      - identity: {}
