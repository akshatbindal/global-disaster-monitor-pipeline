#!/bin/bash

# Deploy Web Application Script
# This script deploys the Streamlit web app to Cloud Run

set -e

echo "🚀 Deploying Web Application to Cloud Run..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

# Navigate to webapp directory
cd ../webapp

# Build and push Docker image
echo "🐳 Building Docker image..."
IMAGE_NAME="gcr.io/$GOOGLE_CLOUD_PROJECT/${WEBAPP_SERVICE_NAME:-disaster-monitor-webapp}"
docker build -t $IMAGE_NAME .

echo "📤 Pushing Docker image..."
docker push $IMAGE_NAME

# Deploy to Cloud Run
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy ${WEBAPP_SERVICE_NAME:-disaster-monitor-webapp} \
    --image=$IMAGE_NAME \
    --platform=managed \
    --region=${GOOGLE_CLOUD_REGION:-us-central1} \
    --allow-unauthenticated \
    --port=${WEBAPP_PORT:-8080} \
    --memory=2Gi \
    --cpu=1 \
    --max-instances=10 \
    --set-env-vars="GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,BIGQUERY_DATASET=${BIGQUERY_DATASET:-disaster_monitor},BIGQUERY_TABLE_EVENTS=${BIGQUERY_TABLE_EVENTS:-disaster_events}"

# Get the service URL
SERVICE_URL=$(gcloud run services describe ${WEBAPP_SERVICE_NAME:-disaster-monitor-webapp} \
    --region=${GOOGLE_CLOUD_REGION:-us-central1} \
    --format="value(status.url)")

echo "✅ Web application deployment complete!"
echo "🌐 Service URL: $SERVICE_URL" 