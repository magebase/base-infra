#!/bin/bash

# YugabyteDB Secret Setup Script
# This script helps populate the YugabyteDB secrets with actual values

set -e

NAMESPACE="yb"
CLUSTER_NAME="${1:-genfix-cluster}"

echo "Setting up YugabyteDB secrets for cluster: $CLUSTER_NAME in namespace: $NAMESPACE"

# Function to generate random password
generate_password() {
    openssl rand -base64 32
}

# Function to base64 encode
encode_base64() {
    echo -n "$1" | base64
}

# Generate database password if not provided
if [ -z "$DB_PASSWORD" ]; then
    DB_PASSWORD=$(generate_password)
    echo "Generated database password"
fi

# Generate R2 credentials if not provided
if [ -z "$R2_ACCESS_KEY" ] || [ -z "$R2_SECRET_KEY" ]; then
    echo "Please provide Cloudflare R2 credentials:"
    read -p "R2 Access Key: " R2_ACCESS_KEY
    read -p "R2 Secret Key: " R2_SECRET_KEY
fi

# Create TLS certificates (self-signed for development)
echo "Generating TLS certificates..."
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/CN=$CLUSTER_NAME.yb.svc.cluster.local"
CA_CERT=$(cat cert.pem | base64 -w 0)
TLS_CERT=$(cat cert.pem | base64 -w 0)
TLS_KEY=$(cat key.pem | base64 -w 0)

# Clean up temporary files
rm -f cert.pem key.pem

# Create secrets using kubectl
echo "Creating database credentials secret..."
kubectl create secret generic yugabyte-db-credentials \
    --namespace=$NAMESPACE \
    --from-literal=username=admin \
    --from-literal=password=$DB_PASSWORD \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Creating TLS certificates secret..."
kubectl create secret generic yugabyte-tls-certs \
    --namespace=$NAMESPACE \
    --from-literal=ca.crt=$CA_CERT \
    --from-literal=tls.crt=$TLS_CERT \
    --from-literal=tls.key=$TLS_KEY \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Creating R2 credentials secret..."
kubectl create secret generic yugabyte-r2-credentials \
    --namespace=$NAMESPACE \
    --from-literal=accessKey=$(encode_base64 "$R2_ACCESS_KEY") \
    --from-literal=secretKey=$(encode_base64 "$R2_SECRET_KEY") \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets created successfully!"
echo "Database password: $DB_PASSWORD"
echo "Make sure to save this password securely!"

# Create KEDA Prometheus authentication secret
echo "Creating KEDA Prometheus authentication secret..."
kubectl create secret generic keda-prometheus-auth \
    --namespace=$NAMESPACE \
    --from-literal=bearerToken="" \
    --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete! Please populate the bearerToken in keda-prometheus-auth secret with a valid Prometheus token."
