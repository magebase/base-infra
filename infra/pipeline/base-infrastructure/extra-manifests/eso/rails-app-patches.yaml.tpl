# Example patches for Rails applications to use database credentials and auto-restart
# These should be applied to your Rails application deployments

# For genfix Rails app
apiVersion: apps/v1
kind: Deployment
metadata:
  name: genfix-rails-app
  namespace: genfix-${ENVIRONMENT}
spec:
  template:
    spec:
      containers:
      - name: rails
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: genfix-database-credentials
              key: DATABASE_URL
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: genfix-database-credentials
              key: DATABASE_PASSWORD
---
# For site Rails app
apiVersion: apps/v1
kind: Deployment
metadata:
  name: site-rails-app
  namespace: site-${ENVIRONMENT}
spec:
  template:
    spec:
      containers:
      - name: rails
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: site-database-credentials
              key: DATABASE_URL
        - name: DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: site-database-credentials
              key: DATABASE_PASSWORD
---
# Annotations for auto-restart on secret changes (Stakater Reloader)
# Add these annotations to your Deployment metadata
metadata:
  annotations:
    reloader.stakater.com/auto: "true"
