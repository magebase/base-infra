apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: postgresql-tls
  namespace: database
  labels:
    environment: ${ENVIRONMENT}
    app.kubernetes.io/name: postgresql
    app.kubernetes.io/component: certificate
spec:
  secretName: postgresql-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - postgresql.${DOMAIN}
    - postgresql.database.svc.cluster.local
    - postgresql.database.svc
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: postgresql-ca
  namespace: database
spec:
  secretName: postgresql-ca
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - postgresql.dev.magebase.dev
    - postgresql.qa.magebase.dev
    - postgresql.uat.magebase.dev
    - postgresql.prod.magebase.dev
  isCA: true
