#!/usr/bin/env python3
"""
Client Configuration Generator

This script reads clients.json and generates various configuration files
to avoid manual duplication of client-specific settings.
"""

import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Any
from jinja2 import Template

class ClientConfigGenerator:
    def __init__(self, clients_file: str):
        self.clients_file = Path(clients_file)
        self.clients = self._load_clients()

    def _load_clients(self) -> List[Dict[str, Any]]:
        """Load clients configuration from JSON file."""
        with open(self.clients_file, 'r') as f:
            return json.load(f)

    def generate_terraform_iam_resources(self) -> str:
        """Generate Terraform IAM resources for external secrets roles."""
        template = """
# AWS IAM users and policies for External Secrets Operator
# Each client gets a scoped user with access only to their parameters
# Since ESO runs in Hetzner k3s (outside AWS), we use access keys instead of role assumption

terraform {
  required_version = ">= 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for current AWS region
data "aws_region" "current" {}

{% for client in clients %}
# IAM policy for {{ client.name }} client - allows access to {{ client.name }} parameters only
resource "aws_iam_policy" "external_secrets_{{ client.name }}" {
  name        = "{{ client.iamPolicyName }}"
  description = "Policy for External Secrets Operator to access {{ client.name }} parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter*",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/{{ client.awsParameterPrefix }}/*"
      }
    ]
  })

  tags = var.tags
}

# IAM user for {{ client.name }} client
resource "aws_iam_user" "external_secrets_{{ client.name }}" {
  name = "{{ client.iamUserName }}"
  tags = var.tags
}

# Access key for {{ client.name }} user
resource "aws_iam_access_key" "external_secrets_{{ client.name }}" {
  user = aws_iam_user.external_secrets_{{ client.name }}.name
}

# Attach policy to {{ client.name }} user
resource "aws_iam_user_policy_attachment" "external_secrets_{{ client.name }}" {
  user       = aws_iam_user.external_secrets_{{ client.name }}.name
  policy_arn = aws_iam_policy.external_secrets_{{ client.name }}.arn
}

{% endfor %}
"""
        return Template(template).render(clients=self.clients)

    def generate_terraform_outputs(self) -> str:
        """Generate Terraform outputs for external secrets roles."""
        template = """
{% for client in clients %}
output "{{ client.name }}_access_key_id" {
  description = "Access Key ID for {{ client.name }} client IAM user"
  value       = aws_iam_access_key.external_secrets_{{ client.name }}.id
  sensitive   = true
}

output "{{ client.name }}_secret_access_key" {
  description = "Secret Access Key for {{ client.name }} client IAM user"
  value       = aws_iam_access_key.external_secrets_{{ client.name }}.secret
  sensitive   = true
}

output "{{ client.name }}_policy_arn" {
  description = "ARN of the IAM policy for {{ client.name }} client"
  value       = aws_iam_policy.external_secrets_{{ client.name }}.arn
}

{% endfor %}
"""
        return Template(template).render(clients=self.clients)

    def generate_secret_stores_template(self) -> str:
        """Generate client-specific SecretStores template."""
        template = """# Client-specific SecretStores with scoped IAM roles
# Each client gets their own SecretStore with limited access to their parameters

{% for client in clients %}
---
apiVersion: external-secrets.io/v1
kind: SecretStore
metadata:
  name: {{ client.secretStoreName }}
  namespace: external-secrets-system
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${AWS_REGION}
      auth:
        secretRef:
          accessKeyIDSecretRef:
            name: {{ client.awsCredentialsSecret }}
            key: access-key-id
          secretAccessKeySecretRef:
            name: {{ client.awsCredentialsSecret }}
            key: secret-access-key

{% endfor %}
"""
        return Template(template).render(clients=self.clients)

    def generate_bash_case_statement(self) -> str:
        """Generate bash case statement for repository handling."""
        template = """# Determine application details
case "$REPOSITORY" in
{% for client in clients %}
    "{{ client.repository }}")
        APP_NAME="{{ client.appNamePattern }}"
        MANIFEST_FILE="{{ client.manifestPathPattern }}"
        ;;
{% endfor %}
    *)
        echo "❌ Unsupported repository: $REPOSITORY"
        exit 1
        ;;
esac"""
        return Template(template).render(clients=self.clients)

    def generate_terraform_variables(self) -> str:
        """Generate Terraform variables for ESO credentials."""
        template = """{% for client in clients %}
variable "eso_{{ client.name }}_access_key_id" {
  description = "Access Key ID for {{ client.name }} External Secrets Operator"
  type        = string
  sensitive   = true
}

variable "eso_{{ client.name }}_secret_access_key" {
  description = "Secret Access Key for {{ client.name }} External Secrets Operator"
  type        = string
  sensitive   = true
}

variable "eso_{{ client.name }}_policy_arn" {
  description = "IAM Policy ARN for {{ client.name }} External Secrets Operator"
  type        = string
}

{% endfor %}"""
        return Template(template).render(clients=self.clients)

    def generate_terraform_locals(self) -> str:
        """Generate Terraform locals for ESO configuration."""
        template = """locals {
{% for client in clients %}
  eso_{{ client.name }}_access_key_id     = base64encode(module.external_secrets_roles.{{ client.name }}_access_key_id)
  eso_{{ client.name }}_secret_access_key = base64encode(module.external_secrets_roles.{{ client.name }}_secret_access_key)
  eso_{{ client.name }}_policy_arn        = module.external_secrets_roles.{{ client.name }}_policy_arn
{% endfor %}
}"""
        return Template(template).render(clients=self.clients)

    def generate_repo_validation(self) -> str:
        """Generate bash repository validation logic."""
        repos = [f'"{client["repository"]}"' for client in self.clients]
        repos.append('"magebase/base-infra"')  # Add base-infra as well

        condition_parts = []
        for repo in repos:
            condition_parts.append(f"$REPO_NAME != {repo}")

        condition = " && ".join(condition_parts)
        repo_list = ", ".join(repos)

        return f"""# Validate repository (dynamically generated from clients.json)
ALLOWED_REPOS=({ " ".join(repos) })
if [[ {condition} ]]; then
  echo "❌ Unauthorized repository: $REPO_NAME"
  echo "Allowed repositories: {repo_list}"
  exit 1
fi"""

    def get_client_names(self) -> List[str]:
        """Get list of client names."""
        return [client['name'] for client in self.clients]

    def get_client_repositories(self) -> List[str]:
        """Get list of client repositories."""
        return [client['repository'] for client in self.clients]

def main():
    if len(sys.argv) != 2:
        print("Usage: python generate_client_configs.py <command>")
        print("Commands:")
        print("  terraform-iam      - Generate Terraform IAM resources")
        print("  terraform-outputs  - Generate Terraform outputs")
        print("  terraform-vars     - Generate Terraform variables")
        print("  terraform-locals   - Generate Terraform locals")
        print("  secret-stores      - Generate SecretStores template")
        print("  bash-case          - Generate bash case statement")
        print("  repo-validation    - Generate repository validation logic")
        print("  client-names       - Print client names")
        print("  repositories       - Print client repositories")
        print("  repo-validation    - Generate repository validation script")
        sys.exit(1)

    # Get the directory of this script
    script_dir = Path(__file__).parent
    clients_file = script_dir / "clients.json"

    generator = ClientConfigGenerator(clients_file)
    command = sys.argv[1]

    if command == "terraform-iam":
        print(generator.generate_terraform_iam_resources())
    elif command == "terraform-outputs":
        print(generator.generate_terraform_outputs())
    elif command == "terraform-vars":
        print(generator.generate_terraform_variables())
    elif command == "terraform-locals":
        print(generator.generate_terraform_locals())
    elif command == "secret-stores":
        print(generator.generate_secret_stores_template())
    elif command == "bash-case":
        print(generator.generate_bash_case_statement())
    elif command == "repo-validation":
        print(generator.generate_repo_validation())
    elif command == "client-names":
        print(" ".join(generator.get_client_names()))
    elif command == "repositories":
        print(" ".join(f'"{repo}"' for repo in generator.get_client_repositories()))
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)

if __name__ == "__main__":
    main()
