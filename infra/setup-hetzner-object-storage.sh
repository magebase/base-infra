#!/bin/bash

# Hetzner Object Storage Setup Script for CloudNativePG Backups
# This script helps you configure Hetzner Object Storage credentials for PostgreSQL backups

set -e

echo "🔧 Hetzner Object Storage Setup for CloudNativePG Backups"
echo "======================================================"

# Check if required tools are installed
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed. Please install Terraform first."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Please install kubectl first."; exit 1; }

# Check if we're in the infra directory
if [ ! -f "main.tf" ] || [ ! -f "kube.tf" ]; then
    echo "❌ Please run this script from the infra/ directory"
    exit 1
fi

echo "📦 Initializing Terraform..."
terraform init

echo ""
echo "🔑 Setting up Hetzner Object Storage..."
echo ""
echo "⚠️  IMPORTANT: Hetzner Object Storage credentials must be created manually:"
echo "   1. Go to https://console.hetzner.cloud"
echo "   2. Navigate to Object Storage"
echo "   3. Create a new bucket (optional - Terraform will create one)"
echo "   4. Go to Credentials/S3 Credentials"
echo "   5. Create S3 credentials with Read/Write permissions"
echo "   6. Note down the Access Key ID and Secret Access Key"
echo ""
echo "📋 Required environment variables for Terraform:"
echo "   - TF_VAR_hetzner_object_storage_access_key"
echo "   - TF_VAR_hetzner_object_storage_secret_key"
echo ""
echo "   Or set them in a terraform.tfvars file:"
echo "   hetzner_object_storage_access_key = \"your-access-key\""
echo "   hetzner_object_storage_secret_key = \"your-secret-key\""
echo ""

read -p "Have you created the Hetzner Object Storage S3 credentials? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Please create the S3 credentials first, then run this script again."
    exit 1
fi

echo ""
echo "🚀 Applying Terraform configuration..."
terraform apply

echo ""
echo "✅ Hetzner Object Storage setup complete!"
echo "=========================================="
BUCKET_NAME=$(terraform output -raw hetzner_object_storage_bucket)
ENDPOINT=$(terraform output -raw hetzner_object_storage_endpoint)

echo "Primary Bucket (MinIO provider): $BUCKET_NAME"
echo "Endpoint: $ENDPOINT"
echo ""

# Generate base64 encoded credentials for Kubernetes secret
if [ -n "$TF_VAR_hetzner_object_storage_access_key" ] && [ -n "$TF_VAR_hetzner_object_storage_secret_key" ]; then
    ACCESS_KEY_B64=$(echo -n "$TF_VAR_hetzner_object_storage_access_key" | base64)
    SECRET_KEY_B64=$(echo -n "$TF_VAR_hetzner_object_storage_secret_key" | base64)

    echo "📄 For your k8s/.env file, add these base64-encoded values:"
    echo "HETZNER_OBJECT_STORAGE_ACCESS_KEY_B64=$ACCESS_KEY_B64"
    echo "HETZNER_OBJECT_STORAGE_SECRET_KEY_B64=$SECRET_KEY_B64"
    echo ""
else
    echo "⚠️  Environment variables not set. Please manually encode your credentials:"
    echo "   echo -n 'your-access-key-id' | base64"
    echo "   echo -n 'your-secret-access-key' | base64"
    echo ""
fi
