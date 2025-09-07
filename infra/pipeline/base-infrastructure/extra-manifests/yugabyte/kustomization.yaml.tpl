apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # YugabyteDB cluster configurations per environment
  - clusters/dev-cluster.yaml.tpl
  - clusters/prod-cluster.yaml.tpl
  - clusters/qa-cluster.yaml.tpl
  - clusters/uat-cluster.yaml.tpl
  - clusters/genfix-cluster.yaml.tpl
  - clusters/site-cluster.yaml.tpl

# Common labels for YugabyteDB clusters
commonLabels:
  app.kubernetes.io/managed-by: yugabyte
  app.kubernetes.io/part-of: yugabyte-clusters
