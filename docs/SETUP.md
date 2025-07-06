# Setup Guide

## Prerequisites

1. **Google Cloud Project**
   - Create a new Google Cloud Project
   - Enable billing
   - Install and configure Google Cloud CLI

2. **Required APIs**
   - Pub/Sub API
   - Dataflow API
   - BigQuery API
   - Vertex AI API
   - Cloud Run API
   - Cloud Functions API
   - Cloud Build API
   - Storage API

3. **API Keys**
   - Google Geocoding API key (optional but recommended)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd global-disaster-monitor-pipeline
```

### 2. Configure Environment

Copy the environment template and update with your values:

```bash
cp env.example .env
# Edit .env with your project details
```

Required variables:
- `GOOGLE_CLOUD_PROJECT`: Your Google Cloud Project ID
- `GOOGLE_GEOCODING_API_KEY`: Google Geocoding API key (optional)

### 3. Deploy Everything

```bash
chmod +x deploy-all.sh
./deploy-all.sh
```

### 4. Load Sample Data

```bash
cd deployment
chmod +x load-sample-data.sh
./load-sample-data.sh
```

## Manual Deployment Steps

If you prefer to deploy components individually:

### 1. Infrastructure
```bash
cd deployment
./deploy-infrastructure.sh
```

### 2. Data Ingestion
```bash
./deploy-data-ingestion.sh
```

### 3. Dataflow Pipeline
```bash
./deploy-dataflow.sh
```

### 4. ML Model
```bash
./deploy-ml-model.sh
```

### 5. Web Application
```bash
./deploy-webapp.sh
```

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   USGS API      │    │  NASA EONET     │    │  Cloud Function │
│   (Earthquakes) │    │   (Natural      │    │   (Data         │
│                 │    │    Events)      │    │   Ingestion)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                        │
                                └────────────┬───────────┘
                                             │
                                    ┌─────────────────┐
                                    │   Pub/Sub       │
                                    │   Topic         │
                                    └─────────────────┘
                                             │
                                    ┌─────────────────┐
                                    │   Dataflow      │
                                    │   Pipeline      │
                                    └─────────────────┘
                                             │
                                    ┌─────────────────┐
                                    │   BigQuery      │
                                    │   (Storage)     │
                                    └─────────────────┘
                                             │
                                    ┌─────────────────┐
                                    │   Vertex AI     │
                                    │   (ML Model)    │
                                    └─────────────────┘
                                             │
                                    ┌─────────────────┐
                                    │   Streamlit     │
                                    │   Web App       │
                                    └─────────────────┘
```

## Monitoring

### Dataflow Jobs
- Monitor at: https://console.cloud.google.com/dataflow/jobs
- Check for any pipeline errors or backlogs

### BigQuery
- View data at: https://console.cloud.google.com/bigquery
- Query disaster events and demographics tables

### Cloud Functions
- Monitor at: https://console.cloud.google.com/functions
- Check function execution logs

### Vertex AI
- Monitor ML model at: https://console.cloud.google.com/vertex-ai
- Check model performance and predictions

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure service accounts have proper IAM roles
   - Check API enablement status

2. **Dataflow Job Failures**
   - Check BigQuery table schemas
   - Verify Pub/Sub topic exists
   - Review Dataflow logs

3. **ML Model Deployment Issues**
   - Ensure Vertex AI API is enabled
   - Check model artifact format
   - Verify endpoint configuration

4. **Web App Deployment Issues**
   - Check Docker build logs
   - Verify Cloud Run service configuration
   - Review environment variables

### Logs and Debugging

```bash
# View Dataflow logs
gcloud dataflow jobs list --project=$GOOGLE_CLOUD_PROJECT

# View Cloud Function logs
gcloud functions logs read disaster-data-ingestion --project=$GOOGLE_CLOUD_PROJECT

# View BigQuery data
bq query --project_id=$GOOGLE_CLOUD_PROJECT "SELECT COUNT(*) FROM \`$GOOGLE_CLOUD_PROJECT.disaster_monitor.disaster_events\`"
```

## Cost Optimization

1. **Dataflow**
   - Use appropriate machine types
   - Set autoscaling parameters
   - Monitor job duration

2. **BigQuery**
   - Use partitioning for large tables
   - Implement data retention policies
   - Optimize query patterns

3. **Vertex AI**
   - Use appropriate machine types for endpoints
   - Consider model versioning for cost control

4. **Cloud Functions**
   - Optimize function execution time
   - Use appropriate memory allocation

## Security Considerations

1. **API Keys**
   - Store securely using Secret Manager
   - Rotate keys regularly
   - Use least privilege access

2. **Service Accounts**
   - Use dedicated service accounts
   - Grant minimal required permissions
   - Monitor access logs

3. **Data Protection**
   - Encrypt data at rest and in transit
   - Implement access controls
   - Regular security audits 