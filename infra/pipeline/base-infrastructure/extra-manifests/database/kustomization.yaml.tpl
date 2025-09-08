apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - database-r2-credentials.yaml
  - operator/rbac.yaml
  - operator/deployment.yaml
  - operator/restapi.yaml
  - operator/certificates.yaml
  - genfix/${ENVIRONMENT}-cluster.yaml
  - genfix/${ENVIRONMENT}-db-url-secret.yaml
  - site/${ENVIRONMENT}-cluster.yaml
  - site/${ENVIRONMENT}-db-url-secret.yaml

namespace: database

# Exclude operator resources from namespace transformation
resourceSelector:
  not:
  - apiVersion: v1
    kind: Namespace
    name: stackgres
  - apiVersion: apps/v1
    kind: Deployment
    name: stackgres-operator
  - apiVersion: v1
    kind: ServiceAccount
    name: stackgres-operator
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    name: stackgres-operator
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    name: stackgres-operator
