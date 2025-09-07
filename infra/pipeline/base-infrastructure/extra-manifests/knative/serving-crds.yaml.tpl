# Knative Serving Custom Resource Definitions
# Template for: https://github.com/knative/serving/releases/download/knative-v1.18.1/serving-crds.yaml

apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: certificates.networking.internal.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: networking.internal.knative.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: certificates
    singular: certificate
    categories:
    - knative-internal
    - networking
    kind: Certificate
    shortNames:
    - kcert

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: configurations.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    duck.knative.dev/podspecable: "true"
    knative.dev/crd-install: "true"
spec:
  group: serving.knative.dev
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: configurations
    singular: configuration
    categories:
    - knative
    - serving
    kind: Configuration
    shortNames:
    - config
    - cfg

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: domainmappings.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: serving.knative.dev
  versions:
  - name: v1beta1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: domainmappings
    singular: domainmapping
    categories:
    - knative
    - serving
    kind: DomainMapping

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: ingresses.networking.internal.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: networking.internal.knative.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: ingresses
    singular: ingress
    categories:
    - knative-internal
    - networking
    kind: Ingress
    shortNames:
    - kingress

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: metrics.autoscaling.internal.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: autoscaling.internal.knative.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: metrics
    singular: metric
    categories:
    - knative-internal
    - autoscaling
    kind: Metric

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: podautoscalers.autoscaling.internal.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: autoscaling.internal.knative.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: podautoscalers
    singular: podautoscaler
    categories:
    - knative-internal
    - autoscaling
    kind: PodAutoscaler
    shortNames:
    - kpa
    - pa

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: revisions.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    duck.knative.dev/podspecable: "true"
    knative.dev/crd-install: "true"
spec:
  group: serving.knative.dev
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: revisions
    singular: revision
    categories:
    - knative
    - serving
    kind: Revision
    shortNames:
    - rev

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: routes.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    duck.knative.dev/addressable: "true"
    knative.dev/crd-install: "true"
spec:
  group: serving.knative.dev
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: routes
    singular: route
    categories:
    - knative
    - serving
    kind: Route
    shortNames:
    - rt

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: services.serving.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    duck.knative.dev/addressable: "true"
    duck.knative.dev/podspecable: "true"
    knative.dev/crd-install: "true"
spec:
  group: serving.knative.dev
  versions:
  - name: v1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: services
    singular: service
    categories:
    - knative
    - serving
    kind: Service
    shortNames:
    - kservice
    - ksvc

---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: serverlessservices.networking.internal.knative.dev
  labels:
    app.kubernetes.io/version: "1.18.1"
    knative.dev/crd-install: "true"
spec:
  group: networking.internal.knative.dev
  versions:
  - name: v1alpha1
    served: true
    storage: true
    subresources:
      status: {}
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
          status:
            type: object
  scope: Namespaced
  names:
    plural: serverlessservices
    singular: serverlessservice
    categories:
    - knative-internal
    - networking
    kind: ServerlessService
    shortNames:
    - sks
