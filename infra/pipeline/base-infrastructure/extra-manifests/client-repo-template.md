# Client Repository Template for Magebase

This template provides the necessary configuration for client repositories to connect to their StackGres database clusters.

## Repository Structure

```text
client-repo/
├── .github/
│   └── workflows/
│       ├── build.yml
│       └── deploy.yml
├── k8s/
│   ├── service.yaml
│   └── kustomization.yaml
└── README.md
```

## GitHub Actions Workflows

### Build Workflow (.github/workflows/build.yml)

```yaml
name: Build and Test
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ vars.AWS_REGION }}

    - name: Fetch DATABASE_URL from SSM
      run: |
        DATABASE_URL=$(aws ssm get-parameter \
          --name "/site/${{ vars.ENVIRONMENT }}/${{ github.repository_owner }}/database/url" \
          --with-decryption \
          --query Parameter.Value \
          --output text)
        echo "DATABASE_URL=$DATABASE_URL" >> $GITHUB_ENV

    - name: Build application
      env:
        DATABASE_URL: ${{ env.DATABASE_URL }}
      run: |
        echo "Building with DATABASE_URL: $DATABASE_URL"
        # Add your build commands here

    - name: Run tests
      env:
        DATABASE_URL: ${{ env.DATABASE_URL }}
      run: |
        echo "Testing with DATABASE_URL: $DATABASE_URL"
        # Add your test commands here
```

### Deploy Workflow (.github/workflows/deploy.yml)

```yaml
name: Deploy to Kubernetes
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure ArgoCD
      run: |
        curl -X POST \
          -H "Authorization: Bearer ${{ secrets.ARGOCD_TOKEN }}" \
          https://argocd.yourdomain.com/api/v1/applications/${{ github.repository_owner }}-app/sync
```

## Kubernetes Configuration

### Knative Service (k8s/service.yaml)

```yaml
apiVersion: serving.knative.dev/v1
kind: Service
metadata:
  name: ${{CLIENT}}-app
  namespace: ${{CLIENT}}-ns
spec:
  template:
    metadata:
      annotations:
        autoscaling.knative.dev/minScale: "0"
        autoscaling.knative.dev/maxScale: "10"
    spec:
      containers:
      - name: app
        image: ${{CLIENT}}-app:latest
        env:
        # Database connection from SSM via External Secrets
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: magebase-app-secrets
              key: DATABASE_URL
        # Application secrets
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: magebase-app-secrets
              key: secret-key-base
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: magebase-app-secrets
              key: api-key
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

### Kustomization (k8s/kustomization.yaml)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- service.yaml

namespace: ${{CLIENT}}-ns

images:
- name: ${{CLIENT}}-app
  newTag: latest
```

## Required GitHub Secrets

Add these secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`: AWS access key with SSM read permissions
- `AWS_SECRET_ACCESS_KEY`: AWS secret key with SSM read permissions
- `ARGOCD_TOKEN`: ArgoCD token for triggering deployments

## Required GitHub Variables

Add these variables to your GitHub repository:

- `AWS_REGION`: AWS region (e.g., us-east-1)
- `ENVIRONMENT`: Environment name (dev, qa, uat, prod)

## ArgoCD Application

Create an ArgoCD application for your client:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${{CLIENT}}-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/${{CLIENT}}-repo
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: ${{CLIENT}}-ns
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Database Connection

Your application will automatically receive the `DATABASE_URL` environment variable containing the connection string to your StackGres database cluster. The connection string format is:

```text
postgresql://username:password@cluster-name.database:5432/database
```

The credentials are automatically rotated and managed by StackGres, and the connection string is kept up-to-date via SSM Parameter Store.
