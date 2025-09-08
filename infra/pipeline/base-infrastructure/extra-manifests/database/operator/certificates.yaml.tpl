apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: stackgres-operator-certs
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: certificates
    app.kubernetes.io/part-of: citus
spec:
  dnsNames:
  - stackgres-operator.stackgres.svc
  - stackgres-operator.stackgres.svc.cluster.local
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: stackgres-operator-certs
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: stackgres-restapi-certs
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-restapi
    app.kubernetes.io/component: certificates
    app.kubernetes.io/part-of: citus
spec:
  dnsNames:
  - stackgres-restapi.stackgres.svc
  - stackgres-restapi.stackgres.svc.cluster.local
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: stackgres-restapi-certs
