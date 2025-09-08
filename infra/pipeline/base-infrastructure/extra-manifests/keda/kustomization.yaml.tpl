apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml

# Common labels for KEDA resources
labels:
  - pairs:
      app.kubernetes.io/managed-by: keda
      app.kubernetes.io/part-of: keda-scaledobjects
