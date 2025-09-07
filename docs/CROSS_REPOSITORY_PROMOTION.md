# Cross-Repository Promotion Trigger Setup

This document explains how to set up automatic promotion triggering from application repositories (genfix, site) to the base-infra repository.

## Overview

When a release is published in `magebase/genfix` or `magebase/site`, it should automatically trigger the promotion workflow in `magebase/base-infra`.

## Setup Steps

### 1. Create Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Create a new token with `repo` scope
3. Copy the token value

### 2. Add Token to Application Repositories

For each application repository (`magebase/genfix`, `magebase/site`):

1. Go to Repository Settings → Secrets and variables → Actions
2. Add a new repository secret named `BASE_INFRA_TRIGGER_TOKEN`
3. Paste the personal access token value

### 3. Add Trigger Workflow

Add the following workflow file to each application repository:

```yaml
# .github/workflows/trigger-base-infra-promotion.yml
name: Trigger Base Infra Promotion

on:
  release:
    types:
      - published

jobs:
  trigger-promotion:
    name: "Trigger Promotion in Base Infra"
    runs-on: ubuntu-latest
    steps:
      - name: Trigger base-infra promotion workflow
        run: |
          curl -X POST \
            -H "Authorization: token ${{ secrets.BASE_INFRA_TRIGGER_TOKEN }}" \
            -H "Accept: application/vnd.github.v3+json" \
            https://api.github.com/repos/magebase/base-infra/dispatches \
            -d '{
              "event_type": "release-published",
              "client_payload": {
                "repository": "${{ github.repository }}",
                "tag": "${{ github.event.release.tag_name }}",
                "from_environment": "dev",
                "to_environment": "prod"
              }
            }'
```

### 4. Alternative: Using GitHub CLI

If you prefer using GitHub CLI instead of curl:

```yaml
# Alternative step using GitHub CLI
- name: Trigger base-infra promotion workflow
  run: |
    gh api repos/magebase/base-infra/dispatches \
      -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -f event_type="release-published" \
      -f client_payload[repository]="${{ github.repository }}" \
      -f client_payload[tag]="${{ github.event.release.tag_name }}" \
      -f client_payload[from_environment]="dev" \
      -f client_payload[to_environment]="prod"
  env:
    GITHUB_TOKEN: ${{ secrets.BASE_INFRA_TRIGGER_TOKEN }}
```

## How It Works

1. When a release is published in genfix or site repository
2. The trigger workflow runs and sends a `repository_dispatch` event to base-infra
3. The base-infra promotion workflow receives the event and starts the promotion process
4. The workflow validates the repository is authorized (only genfix and site allowed)
5. Promotion proceeds with the provided tag and environment information

## Security Notes

- The personal access token only needs `repo` scope
- Only `magebase/genfix` and `magebase/site` repositories are authorized to trigger promotions
- The token should be rotated periodically for security

## Customization

You can customize the `from_environment` and `to_environment` values in the client_payload if you need different promotion paths.
