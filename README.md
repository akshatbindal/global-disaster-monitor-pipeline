# Real-Time Disaster Alert & Impact Assessment System

A comprehensive system for real-time disaster monitoring, advanced data processing, predictive analytics, and automated impact assessment, leveraging a sophisticated suite of Google Cloud Platform services. This project aims to provide timely and actionable insights to mitigate disaster risks and optimize response efforts.

## Core Architecture Flow

The following diagram illustrates the high-level flow of data and major components:

```text
[External Data Sources] ----> | APIs, Feeds, Files | ----> [GCP Ingestion Services]
 (Weather, Seismic,                                         (Cloud Pub/Sub,
  Social Media,                                              Cloud Storage,
  Satellite Imagery)                                         Cloud Functions)
                                                                    |
                                                                    | (Raw & Streamed Data)
                                                                    v
                                          [GCP Processing & Transformation]
                                             (Cloud Dataflow: Stream/Batch)
                                                                    |
                                                                    | (Processed Data, Features)
                                                                    v
                                             [GCP Data Storage & Analytics]
                                               (BigQuery: Data Warehouse,
                                                Cloud Storage: Data Lake)
                                                        |        ^
                                                        |        | (ML Features)
                                                        |        |
                                     +------------------v--------+
                                     | GCP Machine Learning      |
                                     | (Vertex AI: Training,     |
                                     |  Prediction, Pipelines,   |
                                     |  Feature Store)           |
                                     +------------------^--------+
                                                        |        | (Predictions, Insights)
                                                        |        |
                                                        v        |
                                          [GCP Serving & Visualization]
                                             (Cloud Run: Web App,
                                              Looker Studio: Dashboards,
                                              Pub/Sub: Alerts)
```

**Brief Explanation:**

1.  **Data Sources**: Various external sources provide disaster-related data.
2.  **GCP Ingestion**: Data is ingested into Google Cloud using services like Pub/Sub for streams, Cloud Storage for batch files, and Cloud Functions for lightweight processing or triggers.
3.  **GCP Processing**: Cloud Dataflow is the primary engine for both stream and batch data processing, handling transformations, cleaning, and feature engineering.
4.  **GCP Storage & Analytics**: Processed data and ML features are stored in BigQuery (for structured analytics) and Cloud Storage (as a data lake).
5.  **GCP Machine Learning**: Vertex AI is used for the full ML lifecycle – training models, serving predictions, managing features, and orchestrating MLOps pipelines.
6.  **GCP Serving & Visualization**: Insights, predictions, and alerts are delivered via a web application (on Cloud Run), dashboards (Looker Studio), and real-time alerts (Pub/Sub).

## Project Goal and Workflow

This project aims to establish a real-time system for monitoring, processing, and assessing the impact of disasters using Google Cloud Platform. The core workflow is as follows:

1.  **Ingest Data**: Collects real-time and batch data from diverse sources (weather APIs, sensors, satellite imagery, social media).
2.  **Process Data**: Transforms, cleans, enriches, and analyzes the incoming data using stream and batch processing pipelines.
3.  **Store Data**: Stores raw and processed data in a data lake (Cloud Storage) and data warehouse (BigQuery).
4.  **Analyze & Predict**: Leverages data analytics and machine learning models (Vertex AI) for tasks like event detection, impact assessment, and forecasting.
5.  **Visualize & Alert**: Presents insights through dashboards (Looker Studio) and a web application (Streamlit on Cloud Run), and generates alerts for critical events.

The system is designed to be scalable, reliable, and leverage GCP's powerful data engineering and machine learning services.

## Running the Project

This section guides you through setting up and deploying the Real-Time Disaster Alert & Impact Assessment System.

### Prerequisites

1.  **Google Cloud SDK**: Install and initialize the [Google Cloud SDK](https://cloud.google.com/sdk/docs/install). Ensure you have authenticated and set your default project.
    ```bash
    gcloud init
    gcloud auth application-default login
    ```
2.  **Terraform**: Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (version specified in `infrastructure/versions.tf` or project docs, if any).
3.  **Python**: Install Python (e.g., 3.8 or as specified in component `requirements.txt` files).
4.  **GCP Project**: Have a Google Cloud Project with billing enabled.
5.  **Enable APIs**: Ensure the necessary APIs are enabled for your project. This typically includes:
    *   Cloud Resource Manager API
    *   Compute Engine API
    *   BigQuery API
    *   Pub/Sub API
    *   Cloud Storage API
    *   Dataflow API
    *   Vertex AI API
    *   Cloud Functions API
    *   Cloud Run API
    *   Cloud Build API
    *   IAM API
    *   Secret Manager API
    *   (and any others used by specific components like Geocoding API)
    You can enable them via the GCP Console or using `gcloud services enable [SERVICE_NAME]`. The Terraform scripts in `infrastructure/` should also enable required service APIs.

### Setup and Deployment Steps

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Set up Environment Variables**:
    *   Copy the example environment file:
        ```bash
        cp env.example .env
        ```
    *   Edit the `.env` file and populate it with your specific GCP project ID, bucket names, API keys, and other configurations as detailed in the "Environment Variables" section. **Remember to source this file or ensure these variables are available in your shell environment before running deployment scripts if they rely on them.**
        ```bash
        # Example: source .env
        # (Note: .env files are typically gitignored and used for local development. For CI/CD, use service-specific secret management)
        ```

3.  **Deploy Infrastructure**:
    *   The core infrastructure (VPC, BigQuery datasets, Pub/Sub topics, GCS buckets, IAM roles) is provisioned using Terraform.
    *   Navigate to the infrastructure directory and run Terraform:
        ```bash
        cd infrastructure/
        terraform init
        terraform plan
        terraform apply
        cd ..
        ```
    *   Alternatively, use the provided deployment script if it wraps these commands:
        ```bash
        ./deployment/deploy-infrastructure.sh
        ```

4.  **Deploy Application Components**:
    *   The `deployment/` directory contains scripts to deploy individual components. It's recommended to inspect these scripts before running.
    *   The `deploy-all.sh` script might provide a way to deploy all components sequentially.
        ```bash
        ./deploy-all.sh
        ```
    *   **Individual Component Deployment (Example Order)**:
        *   **Data Ingestion (Cloud Functions)**:
            ```bash
            ./deployment/deploy-data-ingestion.sh
            ```
            (This script likely uses `gcloud functions deploy` based on code in `data-ingestion/`)
        *   **Dataflow Pipeline**:
            ```bash
            ./deployment/deploy-dataflow.sh
            ```
            (This script would package the pipeline in `dataflow-pipeline/` and deploy it to Dataflow, potentially as a template or a running job)
        *   **ML Model (Vertex AI)**:
            ```bash
            ./deployment/deploy-ml-model.sh
            ```
            (This script would handle training the model from `ml-model/` and deploying it to a Vertex AI Endpoint)
        *   **Web Application (Cloud Run)**:
            ```bash
            ./deployment/deploy-webapp.sh
            ```
            (This script would build the Docker container from `webapp/Dockerfile` and deploy it to Cloud Run)

5.  **Load Sample Data (Optional)**:
    *   If you want to populate the system with sample data:
        ```bash
        ./deployment/load-sample-data.sh
        ```

6.  **Accessing the System**:
    *   **Web Application**: Once deployed, the URL for the Streamlit web application on Cloud Run will be provided by the deployment script or can be found in the GCP Console.
    *   **BigQuery**: Data can be queried directly in the BigQuery console.
    *   **Looker/Looker Studio**: Dashboards would need to be configured to point to your BigQuery datasets/tables.

### Running Components Locally (Development)

*   **Streamlit Webapp**:
    ```bash
    cd webapp/
    pip install -r requirements.txt
    # Ensure necessary environment variables are set (e.g., for BigQuery access if needed locally)
    streamlit run app.py
    ```
*   **Dataflow Pipelines (Direct Runner)**: Apache Beam pipelines can often be tested locally using the `DirectRunner`. Refer to the `dataflow-pipeline/` directory and Beam documentation.
*   **Cloud Functions**: Can be tested locally using the [Cloud Functions Emulator](https://cloud.google.com/functions/docs/running/calling#local_emulator) or framework-specific tools.

### Important Notes:
*   Review each deployment script in the `deployment/` directory to understand its specific actions and prerequisites.
*   Ensure your GCP user or service account has the necessary IAM permissions to deploy and manage all the resources.
*   The `.ps1` scripts in the `deployment/` directory are for Windows PowerShell users.

## Project Structure

The project is organized as follows:

```
├── .gitignore               # Specifies intentionally untracked files that Git should ignore
├── DEPLOYMENT_SUMMARY.md    # Summary of deployment procedures or status
├── LICENSE                  # Project license file
├── README.md                # This file
├── data-ingestion/          # Scripts for data ingestion (e.g., Cloud Functions source)
│   ├── main.py              # Main Python script for data ingestion logic
│   └── requirements.txt     # Python dependencies for data ingestion
├── dataflow-pipeline/       # Apache Beam pipeline for data processing on Dataflow
│   ├── pipeline.py          # Main Python script for the Beam pipeline
│   ├── requirements.txt     # Python dependencies for the Dataflow pipeline
│   └── setup.py             # Setup script for packaging the Dataflow pipeline
├── deploy-all.sh            # Master script to deploy all components
├── deployment/              # Deployment scripts for various components
│   ├── deploy-data-ingestion.sh # Script to deploy data ingestion components
│   ├── deploy-dataflow.sh     # Script to deploy Dataflow pipeline
│   ├── deploy-infrastructure.sh # Script to deploy GCP infrastructure (likely using Terraform)
│   ├── deploy-ml-model.sh     # Script to deploy the ML model
│   ├── deploy-webapp.sh       # Script to deploy the web application
│   ├── load-sample-data.sh    # Script to load sample data
│   └── *.ps1                  # PowerShell equivalents for Windows users
├── docs/                    # Documentation files
│   └── SETUP.md             # Setup and installation instructions
├── env.example              # Example file for environment variables
├── infrastructure/          # Terraform code for GCP resource provisioning
│   ├── main.tf              # Main Terraform configuration file
│   ├── variables.tf         # Terraform variable definitions
│   └── schemas/             # Directory for data schemas
│       ├── demographics.json
│       └── disaster_events.json
├── ml-model/                # Machine Learning model code and training scripts
│   ├── train_model.py       # Python script for training the ML model
│   └── requirements.txt     # Python dependencies for the ML model
└── webapp/                  # Streamlit web application
    ├── app.py               # Main Python script for the Streamlit app
    ├── Dockerfile           # Dockerfile for containerizing the webapp
    └── requirements.txt     # Python dependencies for the webapp
```

## Environment Variables

Create a `.env` file in the root directory by copying the `env.example` file:

```bash
cp env.example .env
```

Then, populate the `.env` file with your specific configuration values. The required variables are:

```
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT=your-project-id
GOOGLE_CLOUD_REGION=us-central1

# BigQuery Configuration
BIGQUERY_DATASET=disaster_monitor
BIGQUERY_TABLE_EVENTS=disaster_events
BIGQUERY_TABLE_DEMOGRAPHICS=demographics

# Pub/Sub Configuration
PUBSUB_TOPIC=disaster-alerts
PUBSUB_SUBSCRIPTION=disaster-alerts-sub

# Dataflow Configuration
DATAFLOW_JOB_NAME=disaster-pipeline
DATAFLOW_TEMP_LOCATION=gs://your-bucket/temp  # Replace 'your-bucket' with your GCS bucket name
DATAFLOW_STAGING_LOCATION=gs://your-bucket/staging # Replace 'your-bucket' with your GCS bucket name
DATAFLOW_SERVICE_ACCOUNT=dataflow-sa@your-project-id.iam.gserviceaccount.com # Replace with your Dataflow SA

# API Keys (Store sensitive keys in Secret Manager in a real deployment)
USGS_API_BASE_URL=https://earthquake.usgs.gov/earthquakes/feed/v1.0
NASA_EONET_API_BASE_URL=https://eonet.gsfc.nasa.gov/api/v3
GOOGLE_GEOCODING_API_KEY=your-geocoding-api-key # Replace with your actual API key

# Vertex AI Configuration
VERTEX_AI_MODEL_NAME=disaster-impact-model
VERTEX_AI_ENDPOINT_NAME=disaster-impact-endpoint

# Cloud Run Configuration
WEBAPP_SERVICE_NAME=disaster-monitor-webapp
WEBAPP_PORT=8080
```

**Important**:
*   Replace placeholder values like `your-project-id`, `your-bucket`, and `your-geocoding-api-key` with your actual configuration.
*   For production environments, sensitive values such as `GOOGLE_GEOCODING_API_KEY` should be stored securely in [Google Secret Manager](https://cloud.google.com/secret-manager) and accessed by the services at runtime, rather than being hardcoded in the `.env` file or committed to version control. The `.env` file is typically added to `.gitignore`.

## Contributing

We welcome contributions to the Real-Time Disaster Alert & Impact Assessment System! Please see `CONTRIBUTING.md` (you may need to create this file if it doesn't exist) for guidelines on how to:

*   Report bugs and request features.
*   Set up your development environment.
*   Submit pull requests.
*   Follow coding standards and testing procedures.

## License

This project is licensed under the Apache License 2.0. You may need to create a `LICENSE` file with the contents of the Apache License 2.0.