#!/bin/bash

# Interactive script to create kustomization patches for new applications
# This script helps replicate the setup process for regions, environments, and other required patches

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================================${NC}"
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to get user input with validation
get_input() {
    local prompt="$1"
    local default="$2"
    local validation="$3"

    while true; do
        if [ -n "$default" ]; then
            echo -e "${CYAN}$prompt${NC} [${WHITE}$default${NC}]: "
            read -r input
            input="${input:-$default}"
        else
            echo -e "${CYAN}$prompt${NC}: "
            read -r input
        fi

        if [ -z "$validation" ] || eval "$validation"; then
            echo "$input"
            return 0
        else
            print_error "Invalid input. Please try again."
        fi
    done
}

# Function to create directory structure
create_directory_structure() {
    local app_name="$1"
    local regions="$2"
    local environments="$3"

    print_step "Creating directory structure for $app_name"

    # Create base directories
    mkdir -p "infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/$app_name"
    mkdir -p "k8s/base/$app_name"
    mkdir -p "k8s/overlays"

    # Create environment overlays
    IFS=',' read -ra ENV_ARRAY <<< "$environments"
    for env in "${ENV_ARRAY[@]}"; do
        env=$(echo "$env" | xargs)
        mkdir -p "k8s/overlays/$env"
    done

    # Create region-specific directories
    IFS=',' read -ra REGION_ARRAY <<< "$regions"
    for region in "${REGION_ARRAY[@]}"; do
        region=$(echo "$region" | xargs)
        mkdir -p "infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/$app_name/$region"
    done

    print_success "Directory structure created"
}

# Function to create ArgoCD application manifests
create_argocd_manifests() {
    local app_name="$1"
    local regions="$2"
    local environments="$3"
    local repo_url="$4"
    local target_revision="$5"

    print_step "Creating ArgoCD application manifests"

    IFS=',' read -ra REGION_ARRAY <<< "$regions"
    IFS=',' read -ra ENV_ARRAY <<< "$environments"

    for env in "${ENV_ARRAY[@]}"; do
        env=$(echo "$env" | xargs)
        for region in "${REGION_ARRAY[@]}"; do
            region=$(echo "$region" | xargs)

            local manifest_file="infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/$app_name/$region/$app_name-$env-$region.yaml"

            cat > "$manifest_file" << EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $app_name-$env-$region
  namespace: argocd
  labels:
    app: $app_name
    environment: $env
    region: $region
spec:
  project: default
  source:
    repoURL: $repo_url
    targetRevision: $target_revision
    path: k8s/overlays/$env
  destination:
    server: https://kubernetes.default.svc
    namespace: $app_name-$env
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
EOF

            print_success "Created ArgoCD manifest: $manifest_file"
        done
    done
}

# Function to create kustomization files
create_kustomization_files() {
    local app_name="$1"
    local regions="$2"
    local environments="$3"

    print_step "Creating kustomization files"

    # Create base kustomization
    cat > "k8s/base/$app_name/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - deployment.yaml
  - service.yaml
  - configmap.yaml

patchesStrategicMerge: []

patches: []

images:
  - name: $app_name
    newTag: latest
EOF

    print_success "Created base kustomization: k8s/base/$app_name/kustomization.yaml"

    # Create environment-specific kustomizations
    IFS=',' read -ra ENV_ARRAY <<< "$environments"
    for env in "${ENV_ARRAY[@]}"; do
        env=$(echo "$env" | xargs)

        mkdir -p "k8s/overlays/$env/$app_name"

        cat > "k8s/overlays/$env/$app_name/kustomization.yaml" << EOF
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../../base/$app_name

patchesStrategicMerge:
  - $env-patches.yaml

namespace: $app_name-$env
EOF

        # Create environment-specific patches
        cat > "k8s/overlays/$env/$app_name/$env-patches.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
spec:
  replicas: $([ "$env" = "prod" ] && echo "3" || echo "1")
  template:
    spec:
      containers:
      - name: $app_name
        env:
        - name: ENVIRONMENT
          value: "$env"
        resources:
          requests:
            memory: $([ "$env" = "prod" ] && echo "512Mi" || echo "256Mi")
            cpu: $([ "$env" = "prod" ] && echo "500m" || echo "250m")
          limits:
            memory: $([ "$env" = "prod" ] && echo "1Gi" || echo "512Mi")
            cpu: $([ "$env" = "prod" ] && echo "1000m" || echo "500m")
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: $app_name-config
data:
  environment: "$env"
  log_level: $([ "$env" = "prod" ] && echo "info" || echo "debug")
EOF

        print_success "Created environment overlay: k8s/overlays/$env/$app_name/"
    done
}

# Function to create region-specific patches
create_region_patches() {
    local app_name="$1"
    local regions="$2"
    local environments="$3"

    print_step "Creating region-specific patches"

    IFS=',' read -ra REGION_ARRAY <<< "$regions"
    IFS=',' read -ra ENV_ARRAY <<< "$environments"

    for env in "${ENV_ARRAY[@]}"; do
        env=$(echo "$env" | xargs)
        for region in "${REGION_ARRAY[@]}"; do
            region=$(echo "$region" | xargs)

            local patch_file="k8s/overlays/$env/$app_name/$region-patches.yaml"

            cat > "$patch_file" << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $app_name-config
data:
  region: "$region"
  timezone: $(case $region in
    "fsn1") echo "Europe/Berlin" ;;
    "nbg1") echo "Europe/Berlin" ;;
    "hel1") echo "Europe/Helsinki" ;;
    *) echo "UTC" ;;
  esac)
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
spec:
  template:
    spec:
      containers:
      - name: $app_name
        env:
        - name: REGION
          value: "$region"
EOF

            print_success "Created region patch: $patch_file"
        done
    done
}

# Function to update main kustomization files
update_main_kustomizations() {
    local app_name="$1"
    local regions="$2"
    local environments="$3"

    print_step "Updating main kustomization files"

    # Update ArgoCD applications kustomization
    local argocd_kustomization="infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/kustomization.yaml"

    if [ -f "$argocd_kustomization" ]; then
        # Add new app to resources if not already present
        if ! grep -q "$app_name" "$argocd_kustomization"; then
            sed -i "/resources:/a\\  - environments/$app_name/" "$argocd_kustomization"
            print_success "Updated ArgoCD kustomization: $argocd_kustomization"
        else
            print_warning "App $app_name already exists in ArgoCD kustomization"
        fi
    else
        print_warning "ArgoCD kustomization file not found: $argocd_kustomization"
    fi
}

# Function to create sample manifests
create_sample_manifests() {
    local app_name="$1"

    print_step "Creating sample Kubernetes manifests"

    # Create deployment
    cat > "k8s/base/$app_name/deployment.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app_name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $app_name
  template:
    metadata:
      labels:
        app: $app_name
    spec:
      containers:
      - name: $app_name
        image: $app_name:latest
        ports:
        - containerPort: 8080
        env:
        - name: PORT
          value: "8080"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
EOF

    # Create service
    cat > "k8s/base/$app_name/service.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: $app_name
spec:
  selector:
    app: $app_name
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
EOF

    # Create configmap
    cat > "k8s/base/$app_name/configmap.yaml" << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $app_name-config
data:
  app_name: "$app_name"
  version: "1.0.0"
EOF

    print_success "Created sample manifests in k8s/base/$app_name/"
}

# Main function
main() {
    print_header "🚀 New Application Setup Script"
    echo -e "${WHITE}This script will help you create kustomization patches and configurations for a new application.${NC}"
    echo ""

    # Get application details
    APP_NAME=$(get_input "Enter application name" "" "[[ \$input =~ ^[a-z0-9-]+\$ ]] && [[ \${#input} -le 30 ]]")
    REGIONS=$(get_input "Enter regions (comma-separated)" "fsn1,nbg1" "[[ \$input =~ ^[a-z0-9, ]+\$ ]]")
    ENVIRONMENTS=$(get_input "Enter environments (comma-separated)" "dev,prod" "[[ \$input =~ ^[a-z0-9, ]+\$ ]]")
    REPO_URL=$(get_input "Enter Git repository URL" "https://github.com/magebase/$APP_NAME")
    TARGET_REVISION=$(get_input "Enter target revision/branch" "main")

    echo ""
    print_header "📋 Configuration Summary"
    echo -e "${CYAN}Application:${NC} $APP_NAME"
    echo -e "${CYAN}Regions:${NC} $REGIONS"
    echo -e "${CYAN}Environments:${NC} $ENVIRONMENTS"
    echo -e "${CYAN}Repository:${NC} $REPO_URL"
    echo -e "${CYAN}Target Revision:${NC} $TARGET_REVISION"
    echo ""

    # Confirm before proceeding
    CONFIRM=$(get_input "Proceed with creating the application setup? (y/n)" "y")
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        print_warning "Operation cancelled by user"
        exit 0
    fi

    # Execute setup steps
    create_directory_structure "$APP_NAME" "$REGIONS" "$ENVIRONMENTS"
    create_sample_manifests "$APP_NAME"
    create_kustomization_files "$APP_NAME" "$REGIONS" "$ENVIRONMENTS"
    create_region_patches "$APP_NAME" "$REGIONS" "$ENVIRONMENTS"
    create_argocd_manifests "$APP_NAME" "$REGIONS" "$ENVIRONMENTS" "$REPO_URL" "$TARGET_REVISION"
    update_main_kustomizations "$APP_NAME" "$REGIONS" "$ENVIRONMENTS"

    echo ""
    print_header "✅ Setup Complete!"
    echo -e "${GREEN}Application $APP_NAME has been successfully configured!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Review and customize the generated manifests in k8s/base/$APP_NAME/"
    echo "2. Update the Docker image references in the deployment"
    echo "3. Configure any additional environment variables or secrets"
    echo "4. Test the kustomization builds: kubectl kustomize k8s/overlays/<env>/$APP_NAME/"
    echo "5. Commit and push the changes"
    echo "6. The ArgoCD applications will be automatically created via the kustomization"
    echo ""
    echo -e "${BLUE}Generated files:${NC}"
    find "infra/pipeline/base-infrastructure/extra-manifests/argocd/applications/environments/$APP_NAME" -name "*.yaml" 2>/dev/null
    find "k8s" -name "*$APP_NAME*" -type f 2>/dev/null
}

# Run main function
main "$@"
