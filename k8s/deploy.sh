#!/bin/bash

# Magebase Kubernetes Deployment Script
# This script automates the deployment of Magebase to Hetzner k3s clusters

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
K8S_DIR="$PROJECT_ROOT/k8s"

# Default values
ENVIRONMENT="dev"
IMAGE_TAG="latest"
SKIP_BUILD=false
SKIP_DEPLOY=false

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check required tools
    local tools=("docker" "kubectl" "kustomize" "envsubst")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "$tool is not installed or not in PATH"
            exit 1
        fi
    done

    # Check if kubectl is configured
    if ! kubectl cluster-info &> /dev/null; then
        log_error "kubectl is not configured to access a cluster"
        exit 1
    fi

    log_success "All dependencies are available"
}

load_environment() {
    log_info "Loading environment configuration..."

    # Load .env file if it exists
    if [ -f "$PROJECT_ROOT/.env" ]; then
        set -a
        source "$PROJECT_ROOT/.env"
        set +a
        log_success "Loaded environment from .env file"
    else
        log_warning ".env file not found. Using environment variables or defaults."
    fi

    # Set defaults for required variables
    IMAGE_REGISTRY="${IMAGE_REGISTRY:-your-registry.com}"
    IMAGE_NAME="${IMAGE_NAME:-magebase}"
    DOMAIN="${DOMAIN:-magebase.dev}"

    # Validate required variables
    local required_vars=("IMAGE_REGISTRY" "IMAGE_NAME" "DOMAIN")
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Required variable $var is not set"
            exit 1
        fi
    done

    log_success "Environment configuration loaded"
}

build_image() {
    if [ "$SKIP_BUILD" = true ]; then
        log_info "Skipping image build"
        return
    fi

    log_info "Building Docker image..."
    log_info "Image: $IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

    cd "$PROJECT_ROOT"

    # Build the image
    docker build -t "$IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG" .

    # Push the image
    log_info "Pushing image to registry..."
    docker push "$IMAGE_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"

    log_success "Image built and pushed successfully"
}

prepare_manifests() {
    log_info "Preparing Kubernetes manifests for $ENVIRONMENT environment..."

    local overlay_dir="$K8S_DIR/overlays/$ENVIRONMENT"
    local output_file="$overlay_dir/manifests.yaml"

    if [ ! -d "$overlay_dir" ]; then
        log_error "Environment overlay directory not found: $overlay_dir"
        exit 1
    fi

    # Export environment variables for envsubst
    export IMAGE_REGISTRY IMAGE_NAME IMAGE_TAG DOMAIN

    # Generate manifests
    cd "$overlay_dir"
    kustomize build . | envsubst > "$output_file"

    log_success "Manifests prepared: $output_file"
    echo "$output_file"
}

deploy_to_cluster() {
    local manifest_file="$1"
    local namespace="magebase-$ENVIRONMENT"

    if [ "$SKIP_DEPLOY" = true ]; then
        log_info "Skipping deployment"
        return
    fi

    log_info "Deploying to $ENVIRONMENT environment (namespace: $namespace)..."

    # Create namespace if it doesn't exist
    kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -

    # Apply manifests
    kubectl apply -f "$manifest_file" -n "$namespace"

    # Wait for deployment to be ready
    log_info "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/magebase-app -n "$namespace"

    log_success "Deployment completed successfully"
}

verify_deployment() {
    local namespace="magebase-$ENVIRONMENT"

    log_info "Verifying deployment..."

    # Check pod status
    log_info "Pod status:"
    kubectl get pods -n "$namespace"

    # Check services
    log_info "Services:"
    kubectl get services -n "$namespace"

    # Check ingress
    log_info "Ingress:"
    kubectl get ingress -n "$namespace"

    # Test application health (if domain is accessible)
    if curl -f -s "https://$DOMAIN/health" > /dev/null 2>&1; then
        log_success "Application health check passed"
    else
        log_warning "Application health check failed or domain not accessible"
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Magebase to Kubernetes clusters

Options:
    -e, --environment ENV    Target environment (dev, prod) [default: dev]
    -t, --tag TAG           Docker image tag [default: latest]
    --skip-build            Skip Docker image build and push
    --skip-deploy           Skip Kubernetes deployment
    -h, --help              Show this help message

Examples:
    $0                          # Deploy to dev with latest tag
    $0 -e prod -t v1.2.3       # Deploy to prod with specific tag
    $0 --skip-build -e prod     # Deploy existing image to prod

Environment Variables:
    IMAGE_REGISTRY    Docker registry URL
    IMAGE_NAME        Docker image name
    DOMAIN           Application domain
    And other application secrets...
    Note: DATABASE_URL is now generated by CloudNativePG operator

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-deploy)
            SKIP_DEPLOY=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|prod)$ ]]; then
    log_error "Invalid environment: $ENVIRONMENT. Must be 'dev' or 'prod'"
    exit 1
fi

# Main deployment flow
main() {
    log_info "Starting Magebase deployment to $ENVIRONMENT environment"
    log_info "Image tag: $IMAGE_TAG"

    check_dependencies
    load_environment

    if [ "$SKIP_BUILD" = false ]; then
        build_image
    fi

    local manifest_file
    manifest_file=$(prepare_manifests)

    if [ "$SKIP_DEPLOY" = false ]; then
        deploy_to_cluster "$manifest_file"
        verify_deployment
    fi

    log_success "Magebase deployment process completed!"
    log_info "Don't forget to:"
    log_info "  1. Configure DNS records for $DOMAIN"
    log_info "  2. Set up SSL certificates with cert-manager"
    log_info "  3. Configure monitoring dashboards"
    log_info "  4. Set up backup verification"
}

# Run main function
main "$@"
