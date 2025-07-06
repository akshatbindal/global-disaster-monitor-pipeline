# Real-Time Disaster Alert & Impact Assessment System

A comprehensive system for real-time disaster monitoring, data processing, and impact assessment using Google Cloud Platform.

## Architecture

- **Data Ingestion**: Cloud Functions + Pub/Sub
- **Data Processing**: Apache Beam Dataflow Pipeline
- **Data Storage**: BigQuery
- **ML Model**: Vertex AI
- **Visualization**: Looker Studio + Streamlit Web App
- **Deployment**: Cloud Run

## Quick Start

1. Set up Google Cloud Project and enable APIs
2. Deploy infrastructure: `./deploy-infrastructure.sh`
3. Deploy data ingestion: `./deploy-data-ingestion.sh`
4. Deploy data processing: `./deploy-dataflow.sh`
5. Deploy ML model: `./deploy-ml-model.sh`
6. Deploy web app: `./deploy-webapp.sh`

## Project Structure

```
├── infrastructure/          # Terraform infrastructure code
├── data-ingestion/          # Cloud Functions for data ingestion
├── dataflow-pipeline/       # Apache Beam streaming pipeline
├── ml-model/               # Vertex AI ML model
├── webapp/                 # Streamlit web application
├── deployment/             # Deployment scripts
└── docs/                   # Documentation
```

## Environment Variables

Create a `.env` file with:
```
GOOGLE_CLOUD_PROJECT=your-project-id
BIGQUERY_DATASET=disaster_monitor
PUBSUB_TOPIC=disaster-alerts
DATAFLOW_JOB_NAME=disaster-pipeline
``` 