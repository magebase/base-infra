apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - citus-r2-credentials.yaml
  - operator/rbac.yaml
  - operator/deployment.yaml
  - operator/restapi.yaml
  - operator/certificates.yaml
  - genfix/dev-cluster.yaml
  - genfix/qa-cluster.yaml
  - genfix/uat-cluster.yaml
  - genfix/prod-cluster.yaml
  - site/dev-cluster.yaml
  - site/qa-cluster.yaml
  - site/uat-cluster.yaml
  - site/prod-cluster.yaml

namespace: citus
