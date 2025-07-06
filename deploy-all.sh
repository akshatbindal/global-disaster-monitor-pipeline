#!/bin/bash

# Master Deployment Script
# This script deploys the entire disaster monitoring system

set -e

echo "🌍 Real-Time Disaster Alert & Impact Assessment System"
echo "======================================================"

# Check if environment file exists
if [ ! -f "env.example" ]; then
    echo "❌ Error: env.example file not found. Please create it first."
    exit 1
fi

# Load environment variables
export $(cat env.example | grep -v '^#' | xargs)

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set in env.example"
    exit 1
fi

echo "🚀 Starting deployment for project: $GOOGLE_CLOUD_PROJECT"
echo ""

# Step 1: Deploy Infrastructure
echo "📋 Step 1: Deploying Infrastructure..."
cd deployment
./deploy-infrastructure.sh
cd ..

echo ""
echo "✅ Infrastructure deployed successfully!"
echo ""

# Step 2: Deploy Data Ingestion
echo "📋 Step 2: Deploying Data Ingestion..."
cd deployment
./deploy-data-ingestion.sh
cd ..

echo ""
echo "✅ Data ingestion deployed successfully!"
echo ""

# Step 3: Deploy Dataflow Pipeline
echo "📋 Step 3: Deploying Dataflow Pipeline..."
cd deployment
./deploy-dataflow.sh
cd ..

echo ""
echo "✅ Dataflow pipeline deployed successfully!"
echo ""

# Step 4: Deploy ML Model (Optional)
echo "📋 Step 4: Deploying ML Model..."
cd deployment
./deploy-ml-model.sh
cd ..

echo ""
echo "✅ ML model deployed successfully!"
echo ""

# Step 5: Deploy Web Application
echo "📋 Step 5: Deploying Web Application..."
cd deployment
./deploy-webapp.sh
cd ..

echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo ""
echo "Your disaster monitoring system is now live!"
echo ""
echo "📊 Monitor your system:"
echo "   - Dataflow Jobs: https://console.cloud.google.com/dataflow/jobs?project=$GOOGLE_CLOUD_PROJECT"
echo "   - BigQuery: https://console.cloud.google.com/bigquery?project=$GOOGLE_CLOUD_PROJECT"
echo "   - Pub/Sub: https://console.cloud.google.com/cloudpubsub/topic/list?project=$GOOGLE_CLOUD_PROJECT"
echo "   - Cloud Functions: https://console.cloud.google.com/functions/list?project=$GOOGLE_CLOUD_PROJECT"
echo "   - Vertex AI: https://console.cloud.google.com/vertex-ai?project=$GOOGLE_CLOUD_PROJECT"
echo ""
echo "🌐 Web Application: Check the URL from the webapp deployment output"
echo ""
echo "📝 Next Steps:"
echo "   1. Set up your Google Geocoding API key in env.example"
echo "   2. Load demographics data into BigQuery"
echo "   3. Configure alerts and monitoring"
echo "   4. Customize the ML model as needed" 
 