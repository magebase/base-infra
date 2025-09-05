apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  # Order matters: secrets must exist before referencing them in Cluster specs.
  - clusters/genfix-backup-secret.yaml.tpl
  - clusters/site-backup-secret.yaml.tpl
  - clusters/genfix-cluster.yaml.tpl
  - clusters/site-cluster.yaml.tpl

# Common labels for PostgreSQL clusters
commonLabels:
  app.kubernetes.io/managed-by: cloudnative-pg
  app.kubernetes.io/part-of: postgres-clusters
