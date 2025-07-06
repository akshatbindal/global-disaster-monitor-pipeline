#!/bin/bash

# Deploy Data Ingestion Script
# This script deploys the Cloud Function for data ingestion

set -e

echo "🚀 Deploying Data Ingestion Cloud Function..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

# Navigate to data ingestion directory
cd ../data-ingestion

# Deploy Cloud Function
echo "📦 Deploying Cloud Function..."
gcloud functions deploy disaster-data-ingestion \
    --gen2 \
    --runtime=python311 \
    --region=${GOOGLE_CLOUD_REGION:-us-central1} \
    --source=. \
    --entry-point=ingest_disaster_data \
    --trigger-topic=${PUBSUB_TOPIC:-disaster-alerts} \
    --set-env-vars="GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,PUBSUB_TOPIC=${PUBSUB_TOPIC:-disaster-alerts},USGS_API_BASE_URL=${USGS_API_BASE_URL:-https://earthquake.usgs.gov/earthquakes/feed/v1.0},NASA_EONET_API_BASE_URL=${NASA_EONET_API_BASE_URL:-https://eonet.gsfc.nasa.gov/api/v3}" \
    --service-account=${CLOUD_FUNCTION_SERVICE_ACCOUNT:-cloud-function-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com} \
    --memory=512MB \
    --timeout=540s

# Create Cloud Scheduler job to trigger the function every 5 minutes
echo "⏰ Creating Cloud Scheduler job..."
gcloud scheduler jobs create pubsub disaster-data-scheduler \
    --schedule="*/5 * * * *" \
    --topic=${PUBSUB_TOPIC:-disaster-alerts} \
    --message-body="{}" \
    --location=${GOOGLE_CLOUD_REGION:-us-central1} \
    --description="Trigger disaster data ingestion every 5 minutes" \
    || echo "⚠️  Scheduler job may already exist"

echo "✅ Data ingestion deployment complete!" 