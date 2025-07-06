#!/bin/bash

# Deploy Infrastructure Script
# This script deploys the Google Cloud infrastructure using Terraform

set -e

echo "🚀 Deploying Infrastructure..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

# Navigate to infrastructure directory
cd infrastructure

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Plan the deployment
echo "📋 Planning deployment..."
terraform plan \
    -var="project_id=$GOOGLE_CLOUD_PROJECT" \
    -var="region=${GOOGLE_CLOUD_REGION:-us-central1}" \
    -out=tfplan

# Apply the deployment
echo "🔧 Applying infrastructure changes..."
terraform apply tfplan

# Get outputs
echo "📊 Infrastructure outputs:"
terraform output

# Save important values
BUCKET_NAME=$(terraform output -raw dataflow_bucket_name)
DATAFLOW_SA_EMAIL=$(terraform output -raw dataflow_service_account_email)

echo "✅ Infrastructure deployed successfully!"
echo "📦 Dataflow bucket: $BUCKET_NAME"
echo "🔑 Dataflow service account: $DATAFLOW_SA_EMAIL"

# Update environment file with new values
echo "📝 Updating environment variables..."
cat > ../env.example << EOF
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT
GOOGLE_CLOUD_REGION=${GOOGLE_CLOUD_REGION:-us-central1}

# BigQuery Configuration
BIGQUERY_DATASET=disaster_monitor
BIGQUERY_TABLE_EVENTS=disaster_events
BIGQUERY_TABLE_DEMOGRAPHICS=demographics

# Pub/Sub Configuration
PUBSUB_TOPIC=disaster-alerts
PUBSUB_SUBSCRIPTION=disaster-alerts-sub

# Dataflow Configuration
DATAFLOW_JOB_NAME=disaster-pipeline
DATAFLOW_TEMP_LOCATION=gs://$BUCKET_NAME/temp
DATAFLOW_STAGING_LOCATION=gs://$BUCKET_NAME/staging
DATAFLOW_SERVICE_ACCOUNT=$DATAFLOW_SA_EMAIL

# API Keys
USGS_API_BASE_URL=https://earthquake.usgs.gov/earthquakes/feed/v1.0
NASA_EONET_API_BASE_URL=https://eonet.gsfc.nasa.gov/api/v3
GOOGLE_GEOCODING_API_KEY=your-geocoding-api-key

# Vertex AI Configuration
VERTEX_AI_MODEL_NAME=disaster-impact-model
VERTEX_AI_ENDPOINT_NAME=disaster-impact-endpoint

# Cloud Run Configuration
WEBAPP_SERVICE_NAME=disaster-monitor-webapp
WEBAPP_PORT=8080
EOF

echo "✅ Infrastructure deployment complete!" 