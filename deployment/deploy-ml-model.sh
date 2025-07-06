#!/bin/bash

# Deploy ML Model Script
# This script trains and deploys the ML model to Vertex AI

set -e

echo "🚀 Deploying ML Model to Vertex AI..."

# Load environment variables
if [ -f "../env.example" ]; then
    export $(cat ../env.example | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$GOOGLE_CLOUD_PROJECT" ]; then
    echo "❌ Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
fi

# Navigate to ML model directory
cd ../ml-model

# Install dependencies
echo "📦 Installing dependencies..."
pip install -r requirements.txt

# Set environment variable to deploy to Vertex AI
export DEPLOY_TO_VERTEX_AI=true

# Train and deploy the model
echo "🧠 Training and deploying model..."
python train_model.py

# Get the endpoint name from the file
if [ -f "endpoint_name.txt" ]; then
    ENDPOINT_NAME=$(cat endpoint_name.txt)
    echo "✅ Model deployed to endpoint: $ENDPOINT_NAME"
    
    # Update environment file with endpoint name
    echo "📝 Updating environment variables..."
    sed -i "s/VERTEX_AI_ENDPOINT_NAME=.*/VERTEX_AI_ENDPOINT_NAME=$ENDPOINT_NAME/" ../env.example
    
    echo "✅ ML model deployment complete!"
    echo "🔗 Endpoint: $ENDPOINT_NAME"
else
    echo "⚠️  Warning: Endpoint name not found. Model may not have been deployed."
fi 