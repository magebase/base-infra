apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - serving-crds.yaml.tpl
  - serving-core.yaml.tpl
  - kourier.yaml.tpl
  - serving-default-domain.yaml.tpl
  - serving-hpa.yaml.tpl

patchesStrategicMerge:
  - config-network-patch.yaml.tpl

images:
  - name: gcr.io/knative-releases/knative.dev/serving/cmd/controller
    newTag: v1.18.1
  - name: gcr.io/knative-releases/knative.dev/serving/cmd/activator
    newTag: v1.18.1
  - name: gcr.io/knative-releases/knative.dev/serving/cmd/autoscaler
    newTag: v1.18.1
  - name: gcr.io/knative-releases/knative.dev/serving/cmd/webhook
    newTag: v1.18.1
  - name: gcr.io/knative-releases/knative.dev/net-kourier/cmd/controller
    newTag: v1.18.0
  - name: gcr.io/knative-releases/knative.dev/net-kourier/cmd/kourier
    newTag: v1.18.0
