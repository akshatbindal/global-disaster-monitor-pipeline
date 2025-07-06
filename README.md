# Real-Time Disaster Alert & Impact Assessment System

A comprehensive system for real-time disaster monitoring, advanced data processing, predictive analytics, and automated impact assessment, leveraging a sophisticated suite of Google Cloud Platform services. This project aims to provide timely and actionable insights to mitigate disaster risks and optimize response efforts.

## Detailed Architecture

```mermaid
graph TD
    subgraph "External Data Sources"
        DS1[Weather APIs]
        DS2[Seismic Sensors/APIs]
        DS3[Social Media Feeds]
        DS4[Satellite Imagery Providers]
        DS5[IoT Devices]
        DS6[Historical Databases]
    end

    subgraph "Data Ingestion Layer (GCP)"
        direction LR
        GCS_Raw[GCS Buckets: Raw Data Lake]
        PubSub_Ingest[Pub/Sub: Real-time Streams]
        Functions[Cloud Functions: Lightweight Processing/Triggers]
        DataTransfer[Data Transfer Service: Batch Imports]
    end

    subgraph "Data Processing Layer (GCP)"
        direction LR
        Dataflow_Stream[Dataflow: Streaming ETL & Analytics]
        Dataflow_Batch[Dataflow: Batch ETL & ML Prep]
        Dataproc[Dataproc: Spark/Hadoop Processing]
    end

    subgraph "Data Storage & Governance Layer (GCP)"
        direction LR
        GCS_Processed[GCS Buckets: Processed Data]
        BigQuery[BigQuery: Data Warehouse & Analytics Engine]
        Dataplex[Dataplex: Data Governance & Metadata]
    end

    subgraph "Machine Learning Platform (Vertex AI - GCP)"
        direction LR
        FeatureStore[Vertex AI Feature Store]
        Training[Vertex AI Training Custom Models]
        Pipelines[Vertex AI Pipelines MLOps]
        Prediction[Vertex AI Prediction Endpoints/Batch]
        PretrainedAPIs[Vision AI, NLP AI]
    end

    subgraph "Serving & Visualization Layer (GCP & Custom)"
        direction LR
        Looker[Looker/Looker Studio: Dashboards]
        StreamlitApp[Streamlit App on Cloud Run: Interactive UI]
        API_Layer[API Layer: Cloud Endpoints/Apigee]
    end

    subgraph "Orchestration, Monitoring & Security (GCP)"
        direction TB
        Composer[Cloud Composer: Workflow Orchestration]
        Monitoring[Cloud Monitoring: Metrics & Alerts]
        Logging[Cloud Logging: Log Management]
        IAM[IAM: Access Control]
        KMS[KMS: Key Management]
        VPC_SC[VPC Service Controls]
        SecretManager[Secret Manager]
    end

    %% Connections
    DS1 --> PubSub_Ingest
    DS2 --> PubSub_Ingest
    DS3 --> PubSub_Ingest
    DS5 --> PubSub_Ingest
    DS4 --> GCS_Raw
    DS6 --> DataTransfer
    DataTransfer --> GCS_Raw

    PubSub_Ingest --> Dataflow_Stream
    GCS_Raw --> Dataflow_Stream
    GCS_Raw --> Dataflow_Batch
    GCS_Raw --> Dataproc

    Dataflow_Stream --> BigQuery
    Dataflow_Stream --> GCS_Processed
    Dataflow_Stream --> PubSub_Ingest_Alerts[Pub/Sub: Processed Alerts]
    Dataflow_Batch --> BigQuery
    Dataflow_Batch --> GCS_Processed
    Dataproc --> BigQuery
    Dataproc --> GCS_Processed

    BigQuery --> Looker
    BigQuery --> StreamlitApp
    BigQuery --> API_Layer
    BigQuery --> FeatureStore
    GCS_Processed --> FeatureStore

    FeatureStore --> Training
    Training --> Prediction
    Pipelines --> Training
    Pipelines --> Prediction
    PretrainedAPIs -.-> Dataflow_Stream

    PubSub_Ingest_Alerts --> StreamlitApp
    Prediction --> API_Layer
    Prediction --> StreamlitApp

    %% Linking to Orchestration, Monitoring, Security (conceptual links)
    Dataflow_Stream -.-> Composer
    Dataflow_Batch -.-> Composer
    Pipelines -.-> Composer

    GCS_Raw -.-> Dataplex
    BigQuery -.-> Dataplex

    DS1 -.-> IAM & SecretManager
    Functions -.-> IAM & SecretManager
    Dataflow_Stream -.-> Monitoring & Logging & IAM
    Dataflow_Batch -.-> Monitoring & Logging & IAM
    Dataproc -.-> Monitoring & Logging & IAM
    BigQuery -.-> Monitoring & Logging & IAM & KMS & VPC_SC
    GCS_Raw -.-> Monitoring & Logging & IAM & KMS & VPC_SC
    VertexAI_Platform[Vertex AI Platform] -.-> Monitoring & Logging & IAM & KMS
    StreamlitApp -.-> Monitoring & Logging & IAM
    API_Layer -.-> Monitoring & Logging & IAM
    Composer -.-> Monitoring & Logging & IAM

    FeatureStore -.-> VertexAI_Platform
    Training -.-> VertexAI_Platform
    Pipelines -.-> VertexAI_Platform
    Prediction -.-> VertexAI_Platform
    PretrainedAPIs -.-> VertexAI_Platform

end
```

This diagram uses [Mermaid syntax](https://mermaid.js.org/syntax/flowchart.html) which can be rendered by many Markdown viewers (including GitHub).

**Explanation of the Diagram:**

*   **External Data Sources**: Various inputs like weather APIs, sensors, social media, satellite imagery, IoT devices, and historical databases.
*   **Data Ingestion Layer (GCP)**:
    *   **GCS Buckets (Raw Data Lake)**: Stores raw data from batch sources like satellite imagery and historical DBs (via Data Transfer Service).
    *   **Pub/Sub (Real-time Streams)**: Ingests real-time data from APIs, sensors, social media, and IoT.
    *   **Cloud Functions**: Used for lightweight pre-processing or as triggers for ingestion workflows.
    *   **Data Transfer Service**: For scheduled batch imports into GCS.
*   **Data Processing Layer (GCP)**:
    *   **Dataflow (Streaming)**: Processes real-time streams from Pub/Sub and GCS for ETL, analytics, and alert generation. Can also use Pre-trained AI APIs.
    *   **Dataflow (Batch)**: Handles large-scale batch ETL and prepares data for ML training from GCS.
    *   **Dataproc**: For specialized Spark/Hadoop processing on data in GCS.
*   **Data Storage & Governance Layer (GCP)**:
    *   **GCS Buckets (Processed Data)**: Stores outputs from Dataflow/Dataproc.
    *   **BigQuery**: The central data warehouse, stores structured/processed data, serves analytics, and feeds the ML Feature Store.
    *   **Dataplex**: Manages governance, metadata, and data quality across GCS and BigQuery.
*   **Machine Learning Platform (Vertex AI - GCP)**:
    *   **Vertex AI Feature Store**: Manages and serves features for ML models, sourced from BigQuery and GCS.
    *   **Vertex AI Training**: Trains custom ML models.
    *   **Vertex AI Pipelines**: Orchestrates MLOps workflows.
    *   **Vertex AI Prediction**: Serves trained models via endpoints or batch predictions.
    *   **Pre-trained APIs (Vision, NLP)**: Leveraged within Dataflow or other services for specific tasks.
*   **Serving & Visualization Layer (GCP & Custom)**:
    *   **Looker/Looker Studio**: For BI dashboards and reporting from BigQuery.
    *   **Streamlit App on Cloud Run**: Provides an interactive UI, consuming data from BigQuery, Pub/Sub (alerts), and Vertex AI Prediction.
    *   **API Layer (Cloud Endpoints/Apigee)**: Exposes data or model predictions from BigQuery and Vertex AI.
*   **Orchestration, Monitoring & Security (GCP)**:
    *   **Cloud Composer**: Orchestrates Dataflow jobs, Vertex AI Pipelines, etc.
    *   **Cloud Monitoring & Logging**: Centralized monitoring, logging, and alerting for all services.
    *   **IAM, KMS, VPC Service Controls, Secret Manager**: Core security services ensuring access control, key management, perimeter security, and secure secret storage. These are pervasive and apply to most services.

This textual diagram provides a structured overview. In a live GitHub environment, the Mermaid syntax would render a visual graph.

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