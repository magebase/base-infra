#!/bin/bash

# Script to update ArgoCD application targetRevision
# Usage: ./update-argocd-app.sh <repository> <tag> <environment> <region>

set -e

REPOSITORY=$1
TAG=$2
ENVIRONMENT=$3
REGION=$4

if [ -z "$REPOSITORY" ] || [ -z "$TAG" ] || [ -z "$ENVIRONMENT" ] || [ -z "$REGION" ]; then
    echo "❌ Usage: $0 <repository> <tag> <environment> <region>"
    echo "Example: $0 magebase/genfix v1.2.3 dev fsn1"
    exit 1
fi

echo "🔄 Updating ArgoCD application for $REPOSITORY to $TAG in $ENVIRONMENT-$REGION"

# Determine application details
case "$REPOSITORY" in
    "magebase/genfix")
        APP_NAME="magebase-genfix-$ENVIRONMENT-$REGION"
        MANIFEST_FILE="infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/genfix/$ENVIRONMENT-$REGION.yaml.tpl"
        ;;
    "magebase/site")
        APP_NAME="magebase-site-$ENVIRONMENT-$REGION"
        MANIFEST_FILE="infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/site/$ENVIRONMENT-$REGION.yaml.tpl"
        ;;
    *)
        echo "❌ Unsupported repository: $REPOSITORY"
        exit 1
        ;;
esac

# Validate tag format
if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "⚠️  Warning: Tag $TAG does not follow semantic versioning (v1.2.3)"
fi

# Check if manifest file exists
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "❌ Manifest file not found: $MANIFEST_FILE"
    exit 1
fi

echo "📝 Updating $MANIFEST_FILE"

# Backup original file
cp "$MANIFEST_FILE" "${MANIFEST_FILE}.backup"

# Get current targetRevision
CURRENT_REV=$(grep "targetRevision:" "$MANIFEST_FILE" | sed 's/.*targetRevision: *//' | tr -d '\n')

echo "Current targetRevision: $CURRENT_REV"
echo "New targetRevision: $TAG"

# Update targetRevision using yq if available, otherwise sed
if command -v yq &> /dev/null; then
    echo "Using yq to update targetRevision"
    yq -i ".spec.source.targetRevision = \"$TAG\"" "$MANIFEST_FILE"
else
    echo "Using sed to update targetRevision"
    sed -i.bak "s/targetRevision: .*/targetRevision: $TAG/" "$MANIFEST_FILE"
fi

# Verify the change
if grep -q "targetRevision: $TAG" "$MANIFEST_FILE"; then
    echo "✅ Successfully updated targetRevision to $TAG"

    # Show the updated section
    echo "🔍 Updated manifest section:"
    grep -A 10 -B 5 "targetRevision" "$MANIFEST_FILE"

    # Clean up backup
    rm -f "${MANIFEST_FILE}.bak"
else
    echo "❌ Failed to update targetRevision"
    # Restore backup
    mv "${MANIFEST_FILE}.backup" "$MANIFEST_FILE"
    exit 1
fi

# Clean up backup
rm -f "${MANIFEST_FILE}.backup"

echo "🎉 Update completed successfully!"
echo "Application: $APP_NAME"
echo "Environment-Region: $ENVIRONMENT-$REGION"
echo "New Version: $TAG"
