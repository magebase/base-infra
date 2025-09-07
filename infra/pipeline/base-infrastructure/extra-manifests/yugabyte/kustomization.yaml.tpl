apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # YugabyteDB cluster configurations per application and environment
  - genfix/dev-cluster.yaml.tpl
  - genfix/qa-cluster.yaml.tpl
  - genfix/uat-cluster.yaml.tpl
  - genfix/prod-cluster.yaml.tpl
  - site/dev-cluster.yaml.tpl
  - site/qa-cluster.yaml.tpl
  - site/uat-cluster.yaml.tpl
  - site/prod-cluster.yaml.tpl

# Common labels for YugabyteDB clusters
commonLabels:
  app.kubernetes.io/managed-by: yugabyte
  app.kubernetes.io/part-of: yugabyte-clusters
