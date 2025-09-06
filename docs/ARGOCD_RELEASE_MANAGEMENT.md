# ArgoCD Application Release Management

This system automates the deployment of applications to different Hetzner regions when new releases are created in the application repositories.

## Overview

The release management system consists of:

1. **Automated Release Updates**: When a new release is created in `magebase/genfix` or `magebase/site`, the system automatically updates the ArgoCD application manifests in the base-infra repository.

2. **Region-Specific Applications**: Each application has separate ArgoCD applications for each Hetzner region (fsn1, nbg1, hel1, ash, sin).

3. **Multi-Region Deployment**: Applications are deployed simultaneously to all specified regions for true multi-region architecture.

4. **Promotion Workflow**: Manual approval is required to promote applications between regions.

## Infrastructure Architecture

### Multi-Region Setup

- **fsn1 (Frankfurt)**: Primary region with standard configuration (cax11, 1+2 nodes)
- **nbg1 (Nuremberg)**: Production region with HA setup (cax31, 3+5 nodes)
- **hel1 (Helsinki)**: Standard region with medium configuration (cax21, 1+3 nodes)
- **ash (Ashburn)**: US East region with medium configuration (cax21, 1+3 nodes)
- **sin (Singapore)**: Asia Pacific region with medium configuration (cax21, 1+3 nodes)

### Cluster Configuration per Region

Each region has its own dedicated Kubernetes cluster configured via Terragrunt:

```hcl
# Example: regions/fsn1/terragrunt.hcl
inputs = {
  environment = "fsn1"
  domain_name = "fsn1.magebase.dev"
  hetzner_region = "fsn1"
  control_plane_server_type = "cax11"
  agent_server_type = "cax11"
  control_plane_count = 1
  agent_count = 2
}
```

## How It Works

### Release Creation Flow

1. **Developer commits code** to an app repository (e.g., `magebase/genfix`)
2. **CI pipeline runs** tests, builds Docker image, and pushes to registry
3. **CI pipeline creates** a new Git tag (e.g., `v1.2.4`) on the app repository
4. **Release workflow triggers** automatically when the release is published
5. **ArgoCD applications updated** with the new tag in the base-infra repository for all specified regions
6. **PR created** for review and merge
7. **ArgoCD syncs** the new version to all target regions

### Promotion Flow

1. **Application tested** in source region
2. **Promotion workflow triggered** manually with approval
3. **Target region applications updated** with the same tag
4. **PR created** for the target regions
5. **ArgoCD syncs** the new version to the target regions

## Workflows

### `update-argocd-on-release.yml`

Triggers when:

- A release is published in `magebase/genfix` or `magebase/site`
- Manually via workflow dispatch

Actions:

- Updates the specified region ArgoCD applications with the new tag
- Creates a PR for review
- Comments on the release with the PR link

### `promote-app-release.yml`

Triggers when:
- Manually via workflow dispatch

Actions:

- Validates promotion logic for multi-region deployment
- Updates the target region ArgoCD applications
- Creates a PR for the promotion

## Application Structure

```plaintext
infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/
├── regions/
│   ├── magebase-genfix-fsn1.yaml.tpl
│   ├── magebase-genfix-nbg1.yaml.tpl
│   ├── magebase-genfix-hel1.yaml.tpl
│   ├── magebase-genfix-ash.yaml.tpl
│   ├── magebase-genfix-sin.yaml.tpl
│   ├── magebase-site-fsn1.yaml.tpl
│   ├── magebase-site-nbg1.yaml.tpl
│   ├── magebase-site-hel1.yaml.tpl
│   ├── magebase-site-ash.yaml.tpl
│   └── magebase-site-sin.yaml.tpl
└── ...
```

## Helper Scripts

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
   - Run workflow with repository, tag, and regions

2. **Test Promotion**:
   - Go to Actions → "Promote Application Release"
   - Run workflow with repository, tag, source region and target regions

## Region Namespaces

- **fsn1**: `genfix-fsn1`, `site-fsn1`
- **nbg1**: `genfix-nbg1`, `site-nbg1`
- **hel1**: `genfix-hel1`, `site-hel1`
- **ash**: `genfix-ash`, `site-ash`
- **sin**: `genfix-sin`, `site-sin`

## Security Considerations

- All workflows require appropriate GitHub token permissions
- PRs are created for review before deployment
- Manual approval required for region promotions
- Changes are tracked in git history

## Troubleshooting

### Common Issues

1. **Workflow doesn't trigger on release**:
   - Check that the release is published (not just created as draft)
   - Verify repository permissions

2. **Manifest file not found**:
   - Ensure region-specific manifest exists
   - Check file paths in the script

3. **ArgoCD doesn't sync**:
   - Check ArgoCD application status
   - Verify targetRevision was updated correctly
   - Check namespace permissions

### Logs and Debugging

- Check workflow run logs in GitHub Actions
- Review PR descriptions for change details
- Check ArgoCD application status and sync history
