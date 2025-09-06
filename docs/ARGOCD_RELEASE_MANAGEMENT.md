# ArgoCD Application Release Management

This system automates the deployment of applications to different environments when new releases are created in the application repositories.

## Overview

The release management system consists of:

1. **Automated Release Updates**: When a new release is created in `magebase/genfix` or `magebase/site`, the system automatically updates the ArgoCD application manifests in the base-infra repository.

2. **Environment-Specific Applications**: Each application has separate ArgoCD applications for dev, qa, uat, and prod environments.

3. **Promotion Workflow**: Manual approval is required to promote applications between environments (dev → qa → uat → prod).

## How It Works

### Release Creation Flow

1. **Developer commits code** to an app repository (e.g., `magebase/genfix`)
2. **CI pipeline runs** tests, builds Docker image, and pushes to registry
3. **CI pipeline creates** a new Git tag (e.g., `v1.2.4`) on the app repository
4. **Release workflow triggers** automatically when the release is published
5. **ArgoCD application updated** with the new tag in the base-infra repository
6. **PR created** for review and merge
7. **ArgoCD syncs** the new version to the dev environment

### Promotion Flow

1. **Application tested** in current environment
2. **Promotion workflow triggered** manually with approval
3. **Target environment application updated** with the same tag
4. **PR created** for the target environment
5. **ArgoCD syncs** the new version to the target environment

## Workflows

### `update-argocd-on-release.yml`

Triggers when:
- A release is published in `magebase/genfix` or `magebase/site`
- Manually via workflow dispatch

Actions:
- Updates the dev environment ArgoCD application with the new tag
- Creates a PR for review
- Comments on the release with the PR link

### `promote-app-release.yml`

Triggers when:
- Manually via workflow dispatch

Actions:
- Validates promotion order (dev → qa → uat → prod)
- Updates the target environment ArgoCD application
- Creates a PR for the promotion

## Application Structure

```
infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/
├── environments/
│   ├── magebase-genfix-dev.yaml.tpl
│   ├── magebase-genfix-qa.yaml.tpl
│   ├── magebase-genfix-uat.yaml.tpl
│   ├── magebase-genfix-prod.yaml.tpl
│   ├── magebase-site-dev.yaml.tpl
│   ├── magebase-site-qa.yaml.tpl
│   ├── magebase-site-uat.yaml.tpl
│   └── magebase-site-prod.yaml.tpl
└── ...
```

## Scripts

### `scripts/update-argocd-app.sh`

Helper script for updating ArgoCD application manifests.

Usage:
```bash
./scripts/update-argocd-app.sh <repository> <tag> [environment]
```

Example:
```bash
./scripts/update-argocd-app.sh magebase/genfix v1.2.3 dev
```

## Manual Testing

You can test the workflows manually:

1. **Test Release Update**:
   - Go to Actions → "Update ArgoCD Applications on Release"
   - Run workflow with repository, tag, and environment

2. **Test Promotion**:
   - Go to Actions → "Promote Application Release"
   - Run workflow with repository, tag, source and target environments

## Environment Namespaces

- **dev**: `genfix-dev`, `site-dev`
- **qa**: `genfix-qa`, `site-qa`
- **uat**: `genfix-uat`, `site-uat`
- **prod**: `genfix-prod`, `site-prod`

## Security Considerations

- All workflows require appropriate GitHub token permissions
- PRs are created for review before deployment
- Manual approval required for environment promotions
- Changes are tracked in git history

## Troubleshooting

### Common Issues

1. **Workflow doesn't trigger on release**:
   - Check that the release is published (not just created as draft)
   - Verify repository permissions

2. **Manifest file not found**:
   - Ensure environment-specific manifest exists
   - Check file paths in the script

3. **ArgoCD doesn't sync**:
   - Check ArgoCD application status
   - Verify targetRevision was updated correctly
   - Check namespace permissions

### Logs and Debugging

- Check workflow run logs in GitHub Actions
- Review PR descriptions for change details
- Check ArgoCD application status and sync history
