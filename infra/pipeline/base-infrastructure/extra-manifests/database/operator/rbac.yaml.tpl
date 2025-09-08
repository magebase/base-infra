apiVersion: v1
kind: Namespace
metadata:
  name: stackgres
  labels:
    name: stackgres
    app.kubernetes.io/name: stackgres
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: stackgres-operator
  namespace: stackgres
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: stackgres-operator
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
rules:
- apiGroups:
  - ""
  resources:
  - pods
  - pods/exec
  - secrets
  - services
  - endpoints
  - configmaps
  - persistentvolumeclaims
  - events
  - serviceaccounts
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - apps
  resources:
  - deployments
  - daemonsets
  - replicasets
  - statefulsets
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - batch
  resources:
  - jobs
  - cronjobs
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - stackgres.io
  resources:
  - '*'
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - clusterroles
  - clusterrolebindings
  - roles
  - rolebindings
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - networkpolicies
  - ingresses
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
- apiGroups:
  - monitoring.coreos.com
  resources:
  - servicemonitors
  - prometheusrules
  verbs:
  - create
  - get
  - list
  - watch
  - update
  - patch
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: stackgres-operator
  labels:
    app.kubernetes.io/name: stackgres-operator
    app.kubernetes.io/component: operator
    app.kubernetes.io/part-of: citus
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: stackgres-operator
subjects:
- kind: ServiceAccount
  name: stackgres-operator
  namespace: stackgres
