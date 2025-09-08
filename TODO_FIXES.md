# Terraform Deployment Fixes

- [x] Create namespace definitions for genfix-${ENVIRONMENT} and site-${ENVIRONMENT}
- [x] Add namespace resources to the base kustomization.yaml.tpl
- [x] Ensure proper ordering so namespaces are created before dependent resources
- [x] Fix StackGres webhook timing issues by improving readiness checks
- [x] Remove manual StackGres resource application to let ArgoCD handle it with proper sync waves
- [x] Add proper sync wave annotations to all ArgoCD applications and resources for correct deployment ordering
