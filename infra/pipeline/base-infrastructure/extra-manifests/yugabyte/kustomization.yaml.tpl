apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # YugabyteDB cluster configurations
  - clusters/genfix-cluster.yaml.tpl
  - clusters/site-cluster.yaml.tpl

# Common labels for YugabyteDB clusters
commonLabels:
  app.kubernetes.io/managed-by: yugabyte
  app.kubernetes.io/part-of: yugabyte-clusters
