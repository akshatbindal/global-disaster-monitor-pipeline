#!/bin/bash

# Deploy Dataflow Pipeline Script
# This script deploys the Apache Beam Dataflow pipeline

set -e

echo "🚀 Deploying Dataflow Pipeline..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

if [ -z "$GOOGLE_GEOCODING_API_KEY" ]; then
    echo "⚠️  Warning: GOOGLE_GEOCODING_API_KEY not set. Geocoding will be disabled."
fi

# Navigate to dataflow directory
cd ../dataflow-pipeline

# Create staging directories in Cloud Storage
echo "📦 Creating staging directories..."
gsutil mb -p $GOOGLE_CLOUD_PROJECT -c STANDARD -l ${GOOGLE_CLOUD_REGION:-us-central1} gs://$GOOGLE_CLOUD_PROJECT-dataflow || echo "Bucket may already exist"

gsutil -m cp -r requirements.txt gs://$GOOGLE_CLOUD_PROJECT-dataflow/staging/ || true

# Set environment variables for the pipeline
export PYTHONPATH="${PYTHONPATH}:$(pwd)"

# Deploy the Dataflow job
echo "🔧 Deploying Dataflow job..."
python pipeline.py \
    --project=$GOOGLE_CLOUD_PROJECT \
    --region=${GOOGLE_CLOUD_REGION:-us-central1} \
    --temp_location=gs://$GOOGLE_CLOUD_PROJECT-dataflow/temp \
    --staging_location=gs://$GOOGLE_CLOUD_PROJECT-dataflow/staging \
    --service_account_email=${DATAFLOW_SERVICE_ACCOUNT:-dataflow-sa@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com} \
    --runner=DataflowRunner \
    --job_name=${DATAFLOW_JOB_NAME:-disaster-pipeline} \
    --streaming \
    --setup_file=./setup.py \
    --requirements_file=requirements.txt \
    --save_main_session \
    --environment_variables="GOOGLE_GEOCODING_API_KEY=$GOOGLE_GEOCODING_API_KEY,GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT,BIGQUERY_DATASET=${BIGQUERY_DATASET:-disaster_monitor},PUBSUB_TOPIC=${PUBSUB_TOPIC:-disaster-alerts},BIGQUERY_TABLE_EVENTS=${BIGQUERY_TABLE_EVENTS:-disaster_events},VERTEX_AI_ENDPOINT_NAME=$VERTEX_AI_ENDPOINT_NAME"

echo "✅ Dataflow pipeline deployment complete!"
echo "📊 Monitor the job at: https://console.cloud.google.com/dataflow/jobs?project=$GOOGLE_CLOUD_PROJECT" 