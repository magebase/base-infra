# Dynamic Client Configuration

This directory contains a dynamic client configuration system that eliminates manual duplication of client-specific settings across the infrastructure codebase.

## Overview

Instead of manually listing client repositories and their configurations in multiple places, all client information is now centralized in `clients.json` and dynamically generated where needed.

## Files

- `clients.json` - Central configuration file containing all client definitions
- `generate_client_configs.py` - Python script to generate various configuration files from clients.json

## Client Configuration Structure

Each client in `clients.json` has the following properties:

```json
{
  "name": "genfix",
  "clusterType": "sgcluster",
  "repository": "magebase/genfix",
  "awsParameterPrefix": "genfix",
  "appNamePattern": "magebase-genfix-{environment}-{region}",
  "manifestPathPattern": "infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/genfix/{environment}-{region}.yaml.tpl",
  "secretStoreName": "genfix-secret-store",
  "awsCredentialsSecret": "genfix-aws-credentials",
  "iamUserName": "external-secrets-genfix",
  "iamPolicyName": "external-secrets-genfix-policy"
}
```

## Adding a New Client

To add a new client:

1. Add a new entry to `clients.json` with all required properties
2. Run the generation scripts to update all dependent files:

   ```bash
   python3 generate_client_configs.py terraform-iam > modules/external-secrets-roles/main.tf
   python3 generate_client_configs.py terraform-outputs > modules/external-secrets-roles/outputs.tf
   python3 generate_client_configs.py secret-stores > extra-manifests/eso/client-secret-stores.yaml.tpl
   ```

3. Update any Terraform variable definitions if needed
4. The GitHub workflows will automatically pick up the new client

## Generated Files

The following files are dynamically generated from `clients.json`:

- `modules/external-secrets-roles/main.tf` - AWS IAM resources for ESO
- `modules/external-secrets-roles/outputs.tf` - Terraform outputs
- `extra-manifests/eso/client-secret-stores.yaml.tpl` - Kubernetes SecretStore templates
- Repository validation logic in GitHub workflows

## Benefits

1. **Single Source of Truth** - All client configuration in one place
2. **DRY Principle** - No manual duplication of client-specific settings
3. **Easy Maintenance** - Adding/removing clients requires changes in only one file
4. **Consistency** - Generated configurations are guaranteed to be consistent
5. **Extensibility** - Easy to add new properties and generation targets

## Usage in Scripts

The `generate_client_configs.py` script supports various commands:

```bash
```bash
# Generate Terraform IAM resources
python3 generate_client_configs.py terraform-iam

# Generate Terraform outputs
python3 generate_client_configs.py terraform-outputs

# Generate SecretStore templates
python3 generate_client_configs.py secret-stores

# Generate bash case statements
python3 generate_client_configs.py bash-case

# Generate repository validation logic
python3 generate_client_configs.py repo-validation

# Get list of client names
python3 generate_client_configs.py client-names

# Get list of repositories
python3 generate_client_configs.py repositories

## Integration Points

The dynamic configuration is used in:

1. **Terraform**: IAM roles, policies, and users for External Secrets Operator
2. **Kubernetes**: SecretStore configurations
3. **GitHub Workflows**: Repository validation and ESO variable handling
4. **Scripts**: Application deployment and ArgoCD management

This system ensures that any changes to client configuration are automatically propagated to all dependent systems.
