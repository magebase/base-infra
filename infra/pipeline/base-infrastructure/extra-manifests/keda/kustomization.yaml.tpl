apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # KEDA scaled objects for event-driven autoscaling
  - scaledobjects/http-scaledobject.yaml.tpl
  - scaledobjects/cpu-scaledobject.yaml.tpl
  - scaledobjects/prometheus-scaledobject.yaml.tpl

# Common labels for KEDA resources
commonLabels:
  app.kubernetes.io/managed-by: keda
  app.kubernetes.io/part-of: keda-scaledobjects
