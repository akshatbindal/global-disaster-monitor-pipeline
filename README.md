# Real-Time Disaster Alert & Impact Assessment System

A comprehensive system for real-time disaster monitoring, advanced data processing, predictive analytics, and automated impact assessment, leveraging a sophisticated suite of Google Cloud Platform services. This project aims to provide timely and actionable insights to mitigate disaster risks and optimize response efforts.

## Key Features

*   **Multi-Source Data Ingestion**: Ingests data from a wide array of sources including real-time sensor networks, weather APIs, satellite imagery, social media feeds, and public datasets.
*   **Real-time Processing & Alerting**: Employs stream processing for immediate data analysis, anomaly detection, and generation of actionable alerts.
*   **Advanced Analytics & ML**: Utilizes machine learning models for predictive forecasting of disaster events, automated damage assessment from imagery, and optimization of resource allocation for response efforts.
*   **Scalable Data Infrastructure**: Built on a serverless and managed GCP backbone, ensuring high scalability and reliability to handle fluctuating data loads and processing demands.
*   **Comprehensive Data Governance**: Implements data discovery, quality checks, and metadata management using Dataplex.
*   **Interactive Visualization & Reporting**: Offers intuitive dashboards (Looker Studio/Looker) and a web application (Streamlit) for situational awareness, impact analysis, and decision support.
*   **End-to-End MLOps**: Leverages Vertex AI for a streamlined machine learning lifecycle, from feature engineering to model deployment and monitoring.
*   **Robust Security**: Incorporates GCP's security best practices, including IAM, VPC Service Controls, and data encryption.

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
    PretrainedAPIs -.-> Dataflow_Stream  # Used within processing

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

## Architecture Overview

This system is built upon a microservices-style architecture on Google Cloud, designed for scalability, resilience, and maintainability. Key components include:

- **Data Ingestion**: A multi-source ingestion layer using **Cloud Pub/Sub** for real-time event streams (e.g., sensor data, social media updates, weather alerts) and **Cloud Storage** buckets for batch data (e.g., satellite imagery, historical datasets). **Cloud Functions** act as lightweight processors or forwarders for specific data sources. **Data Transfer Service** is utilized for scheduled transfers from external sources.
- **Data Processing**:
    - **Real-time Stream Processing**: **Apache Beam pipelines running on Cloud Dataflow** for complex event processing, data transformation, enrichment (joining with geospatial data from BigQuery, external APIs), real-time anomaly detection, and alert generation.
    - **Batch Processing**: **Cloud Dataflow** for large-scale batch transformations and data preparation for ML model training. **Cloud Dataproc** for Spark-based ETL and specialized analytics on massive datasets stored in Cloud Storage.
- **Data Lake & Warehouse**:
    - **Cloud Storage**: Serves as the primary data lake, storing raw ingested data (JSON, AVRO, Parquet, TIFFs for imagery), processed datasets, and staging data for Dataflow/Dataproc jobs.
    - **BigQuery**: Acts as the central data warehouse for structured and semi-structured data. It stores processed data, ML features, analytical tables, and serves as the primary source for BI/visualization tools and ad-hoc querying.
    - **Dataplex**: Provides data governance, metadata management, data discovery, and data quality checks across Cloud Storage and BigQuery.
- **Machine Learning & AI**:
    - **Vertex AI Platform**: A unified ML platform for the entire ML lifecycle.
        - **Vertex AI Pipelines**: For orchestrating and automating ML workflows (training, evaluation, deployment).
        - **Vertex AI Training**: For training custom models (TensorFlow, PyTorch, scikit-learn) for tasks like disaster event prediction, damage assessment from imagery, and resource allocation optimization.
        - **Vertex AI Prediction**: For deploying models as scalable endpoints for real-time predictions and batch predictions.
        - **Vertex AI Feature Store**: For managing, sharing, and serving ML features.
        - **Pre-trained APIs**: Leveraging Google's Vision AI, Natural Language AI for specific tasks like image analysis and text processing from social media.
- **Orchestration**:
    - **Cloud Composer (Managed Apache Airflow)**: For orchestrating complex batch data pipelines, ML training workflows, and other scheduled operational tasks.
- **Serving & Visualization**:
    - **Looker Studio / Looker**: For creating interactive dashboards and reports for situational awareness, impact assessment summaries, and operational monitoring.
    - **Streamlit Web Application (hosted on Cloud Run)**: Provides a user-friendly interface for specific interactive analyses, scenario modeling, and detailed alert investigation.
    - **API Layer (Cloud Endpoints / Apigee)**: Exposes processed data, model predictions, or specific functionalities to external systems or partner applications.
- **Deployment & CI/CD**:
    - **Cloud Build**: For automating the build, test, and deployment of services (Cloud Functions, Dataflow templates, Cloud Run applications, Vertex AI models).
    - **Infrastructure as Code (Terraform)**: Managed in the `infrastructure/` directory for provisioning and managing GCP resources.
    - **Artifact Registry**: For storing container images and other build artifacts.
- **Monitoring & Logging**:
    - **Cloud Monitoring**: For collecting metrics, setting up dashboards, and alerting on system health and performance.
    - **Cloud Logging**: For centralized log management and analysis.

## Data Sources

The system ingests data from a variety of sources to provide a comprehensive view of potential and ongoing disasters:

*   **Meteorological Data**:
    *   Real-time weather APIs (e.g., OpenWeatherMap, AccuWeather) for temperature, precipitation, wind speed, humidity.
    *   NOAA GOES/POES satellite data for weather patterns and storm tracking.
    *   Doppler radar feeds for severe weather detection.
*   **Seismic Data**:
    *   USGS Earthquake API and other global seismological network feeds for earthquake events and magnitudes.
    *   IoT sensors for ground motion detection in critical areas.
*   **Hydrological Data**:
    *   River gauge data from national/local water agencies.
    *   Flood sensors and remote sensing data for water level monitoring.
*   **Social Media Feeds**:
    *   Twitter API, Facebook API (via authorized partners) for public posts related to disasters (requires careful filtering and NLP).
    *   News APIs (e.g., GDELT, NewsAPI) for event detection and situational reports.
*   **Satellite Imagery**:
    *   Sentinel Hub, Landsat, Planet API for pre- and post-disaster imagery (optical and SAR).
    *   Used for damage assessment, land use change detection, and monitoring environmental impacts.
*   **Geospatial Data**:
    *   OpenStreetMap, Google Maps APIs for base maps, road networks, points of interest.
    *   Demographic data, critical infrastructure locations (hospitals, shelters).
*   **Historical Disaster Data**:
    *   Databases like EM-DAT, NOAA's Storm Events Database for model training and comparative analysis.
*   **Crowdsourced Data**:
    *   Reports from citizen science platforms or dedicated disaster reporting apps.

## Data Processing Stages

The core data processing is handled by Apache Beam pipelines on Cloud Dataflow, encompassing several stages:

1.  **Ingestion & Normalization**:
    *   Receiving data from various Pub/Sub topics and GCS landing zones.
    *   Parsing different data formats (JSON, XML, CSV, AVRO, binary sensor data, raster imagery).
    *   Schema validation and transformation to a unified internal data model.
2.  **Data Cleaning & Quality Checks**:
    *   Handling missing values, outlier detection, and data type correction.
    *   Duplicate record identification and merging.
    *   Applying rules defined in Dataplex for data quality.
3.  **Enrichment**:
    *   **Geospatial Enrichment**: Geocoding addresses, reverse geocoding coordinates, associating data with administrative boundaries or affected areas using BigQuery GIS functions.
    *   **Temporal Enrichment**: Aligning data to common time windows, calculating time-based features.
    *   **Contextual Enrichment**: Joining with historical data, demographic information, or infrastructure data from BigQuery or external APIs.
4.  **Real-time Analytics & Anomaly Detection**:
    *   Windowing operations for time-series analysis on streaming data.
    *   Applying statistical methods or ML models to detect unusual patterns or thresholds indicative of a potential disaster (e.g., sudden rise in water levels, unusual seismic activity).
    *   Generating immediate alerts to a dedicated Pub/Sub topic for downstream notification systems.
5.  **Feature Engineering for ML**:
    *   Creating relevant features from raw and processed data for training various ML models.
    *   Storing features in Vertex AI Feature Store for reusability and consistency.
6.  **Batch Processing & Aggregation**:
    *   Performing large-scale aggregations for historical analysis and reporting.
    *   Preparing training datasets for complex ML models (e.g., image segmentation models for damage assessment).
    *   Loading processed and aggregated data into BigQuery analytical tables.
7.  **Output & Serving**:
    *   Writing processed data to BigQuery for warehousing and analytics.
    *   Pushing critical alerts and events to Pub/Sub for real-time dashboards and notifications.
    *   Storing processed files (e.g., map tiles, processed imagery) in Cloud Storage for serving.

## Machine Learning Models

The system leverages Vertex AI to develop, deploy, and manage a suite of machine learning models:

1.  **Event Detection & Early Warning**:
    *   **Time-series forecasting models** (e.g., ARIMA, Prophet, LSTMs) on sensor data (seismic, hydrological, meteorological) to predict potential hazardous events.
    *   **Natural Language Processing (NLP) models** (e.g., BERT-based classifiers, topic models) on social media and news feeds to detect early mentions of disasters and assess sentiment.
2.  **Impact Assessment & Severity Prediction**:
    *   **Computer Vision models** (e.g., CNNs like U-Net, Mask R-CNN) on satellite/aerial imagery for automated damage assessment (building damage, flood extent mapping).
    *   **Regression models** to predict the potential economic impact or number of people affected based on event characteristics and historical data.
3.  **Resource Allocation & Optimization**:
    *   **Optimization models** (e.g., linear programming, reinforcement learning) to suggest optimal allocation of emergency resources (personnel, supplies, equipment) based on predicted impact and available resources.
4.  **Information Verification & Fake News Detection**:
    *   **Classification models** to help identify misinformation or unverified reports from social media during a crisis.
5.  **MLOps**:
    *   **Vertex AI Pipelines** are used to automate the entire ML workflow: data ingestion, preprocessing, feature engineering, model training, evaluation, registration, and deployment.
    *   **Vertex AI Model Monitoring** to track model performance and detect drift or skew, triggering retraining pipelines as needed.

## Security and Compliance

Security is a critical aspect of the system, addressed through multiple layers:

*   **Identity and Access Management (IAM)**: Granular control over who can access which GCP resources, adhering to the principle of least privilege. Service accounts are used for applications and services with specific roles.
*   **VPC Service Controls**: Creates security perimeters around GCP resources to prevent data exfiltration.
*   **Data Encryption**:
    *   Data at rest in Cloud Storage, BigQuery, and other services is encrypted by default. Customer-Managed Encryption Keys (CMEK) via Cloud KMS can be used for enhanced control.
    *   Data in transit is encrypted using TLS.
*   **Secret Management**: Sensitive information like API keys, database credentials are stored in **Google Secret Manager** and accessed securely by applications.
*   **Data Loss Prevention (DLP) API**: Used to scan and classify sensitive data within Cloud Storage and BigQuery, and to apply masking or redaction techniques if necessary.
*   **Network Security**: Firewall rules, private Google access for services, and secure API gateways (Cloud Endpoints/Apigee).
*   **Audit Logging**: Cloud Audit Logs provide a trail of administrative actions and data access.
*   **Compliance**: Designed to support compliance with relevant regulations (e.g., GDPR, HIPAA, if applicable to the data being processed) through GCP's compliance certifications and provided tools. Regular security assessments and penetration testing are recommended.

## Monitoring and Alerting

Comprehensive monitoring and alerting are implemented using Cloud Operations Suite:

*   **Cloud Monitoring**:
    *   Collects metrics from all GCP services used (Dataflow, Pub/Sub, BigQuery, Vertex AI, Cloud Run, etc.).
    *   Custom metrics from applications and data pipelines.
    *   Dashboards for visualizing system health, data pipeline throughput, ML model performance, and resource utilization.
    *   Alerting policies based on thresholds, anomalies, or specific log patterns to notify operations teams of issues or critical events.
*   **Cloud Logging**:
    *   Centralized logging for all services and applications.
    *   Log-based metrics and alerts.
    *   Integration with BigQuery for advanced log analysis.
*   **Application Performance Management (APM)**: Cloud Trace and Profiler can be used for debugging and performance optimization of custom applications.

## Scalability and Reliability

The system is designed for high scalability and reliability:

*   **Managed Services**: Leverages GCP's managed services (Dataflow, BigQuery, Pub/Sub, Vertex AI, Cloud Run) which offer auto-scaling capabilities and built-in fault tolerance.
*   **Serverless Architecture**: Cloud Functions and Cloud Run scale automatically based on load, from zero to many instances.
*   **Dataflow Autoscaling**: Dataflow pipelines can automatically scale worker resources up or down based on workload. Streaming pipelines use features like Streaming Engine for improved performance and scalability.
*   **BigQuery**: Scales seamlessly to handle petabytes of data and complex queries.
*   **Global Infrastructure**: GCP's global network and regional resource deployment options allow for high availability and disaster recovery configurations.
*   **Redundancy**: Pub/Sub topics and BigQuery datasets can be configured for regional or multi-regional redundancy. Cloud Storage offers various storage classes with different redundancy options.
*   **Infrastructure as Code (IaC)**: Terraform allows for repeatable and reliable infrastructure deployment and updates.
*   **CI/CD Pipelines**: Automated build, test, and deployment processes using Cloud Build reduce manual errors and ensure consistency.

## Quick Start

This section provides a high-level overview of the deployment process. Detailed instructions for each component can be found in their respective directories and in the `deployment/` folder.

1.  **Prerequisites**:
    *   Google Cloud SDK installed and configured.
    *   Terraform installed.
    *   Python 3.8+ and pip installed.
    *   Access to a Google Cloud Project with billing enabled.
    *   Required APIs enabled (see `infrastructure/main.tf` or scripts for details).
2.  **Set up Environment Variables**: Copy `.env.example` to `.env` and populate with your project-specific values.
3.  **Deploy Infrastructure**: Navigate to `infrastructure/` and run `terraform init` followed by `terraform apply`. This will provision core resources like GCS buckets, Pub/Sub topics, BigQuery datasets, VPC networks, etc.
4.  **Deploy Data Ingestion Components**:
    *   Deploy Cloud Functions: Refer to `data-ingestion/functions/` and use `gcloud functions deploy...` or provided scripts.
    *   Configure Data Transfer Service jobs if needed.
5.  **Deploy Data Processing Pipelines**:
    *   Build and deploy Dataflow templates: Refer to `dataflow-pipeline/` (both streaming and batch).
    *   Schedule Dataflow jobs or set up triggers.
    *   Deploy Dataproc cluster configurations if used.
6.  **Deploy ML Models & Pipelines**:
    *   Run Vertex AI training pipelines: Refer to `ml-model/pipelines/`.
    *   Deploy trained models to Vertex AI Endpoints.
    *   Configure Vertex AI Feature Store.
7.  **Deploy Web Application & APIs**:
    *   Build and deploy the Streamlit web application to Cloud Run: Refer to `webapp/`.
    *   Configure Cloud Endpoints or Apigee for the API layer if applicable.
8.  **Configure Orchestration**:
    *   Deploy DAGs to Cloud Composer: Refer to `orchestration/dags/`.
9.  **Set up Monitoring & Alerting**:
    *   Create custom dashboards and alert policies in Cloud Monitoring.

## Project Structure

The project is organized to separate concerns for different components of the system:

```
├── infrastructure/          # Terraform code for GCP resource provisioning (VPC, Buckets, BigQuery Datasets, Pub/Sub, IAM)
│   ├── modules/             # Reusable Terraform modules
│   └── main.tf              # Main infrastructure configuration
├── data-ingestion/          # Components for ingesting data from various sources
│   ├── functions/           # Cloud Functions for lightweight, event-driven data handling
│   ├── data-transfer-configs/ # Configurations for GCP Data Transfer Service
│   └── scripts/             # Helper scripts for deployment or setup
├── dataflow-pipeline/       # Apache Beam pipelines for stream and batch processing
│   ├── streaming/           # Real-time data processing pipelines
│   ├── batch/               # Batch data processing pipelines
│   └── templates/           # Dataflow templates
├── dataproc-jobs/           # Spark jobs or other configurations for Cloud Dataproc (if used)
│   └── pyspark/
├── ml-model/                # Machine Learning models, training, and deployment resources
│   ├── training/            # Scripts and notebooks for model training (e.g., TensorFlow, PyTorch, Scikit-learn)
│   ├── pipelines/           # Vertex AI Pipeline definitions (e.g., Kubeflow Pipelines DSL)
│   ├── feature-store/       # Configurations for Vertex AI Feature Store
│   └── serving/             # Code for custom prediction routines or model deployment
├── orchestration/           # Workflow orchestration using Cloud Composer (Apache Airflow)
│   └── dags/                # Airflow DAG definitions
├── webapp/                  # Streamlit web application for visualization and interaction
│   ├── pages/
│   └── main_app.py
├── api/                     # API definitions and configurations (e.g., Cloud Endpoints, Apigee)
├── deployment/              # Deployment scripts, CI/CD configurations (Cloud Build YAMLs)
│   ├── cloudbuild/
│   └── scripts/
├── docs/                    # System documentation, design documents, and user guides
├── tests/                   # Unit, integration, and end-to-end tests
│   ├── unit/
│   └── integration/
├── .env.example             # Example environment variables file
└── README.md                # This file
```

## Environment Variables

Create a `.env` file by copying `.env.example` and populate it with your specific configuration. Key variables include:

```
# GCP Configuration
GOOGLE_CLOUD_PROJECT=your-project-id
GCP_REGION=your-gcp-region # e.g., us-central1
GCP_ZONE=your-gcp-zone   # e.g., us-central1-a

# BigQuery
BIGQUERY_DATASET_RAW=disaster_monitor_raw
BIGQUERY_DATASET_PROCESSED=disaster_monitor_processed
BIGQUERY_DATASET_ML_FEATURES=disaster_monitor_ml_features

# Pub/Sub Topics
PUBSUB_TOPIC_INGEST_EVENTS=disaster-raw-events # For generic incoming events
PUBSUB_TOPIC_WEATHER_ALERTS=weather-alerts-stream
PUBSUB_TOPIC_SOCIAL_MEDIA=social-media-feed
PUBSUB_TOPIC_PROCESSED_ALERTS=disaster-processed-alerts # For alerts generated by Dataflow

# Cloud Storage Buckets
GCS_BUCKET_RAW_DATA=gs://your-project-id-raw-data-lake
GCS_BUCKET_PROCESSED_DATA=gs://your-project-id-processed-data
GCS_BUCKET_DATAFLOW_STAGING=gs://your-project-id-dataflow-staging
GCS_BUCKET_DATAFLOW_TEMPLATES=gs://your-project-id-dataflow-templates
GCS_BUCKET_ML_MODELS=gs://your-project-id-ml-models
GCS_BUCKET_TERRAFORM_STATE=gs://your-project-id-tf-state # For remote Terraform state

# Dataflow
DATAFLOW_STREAMING_JOB_NAME=disaster-streaming-pipeline
DATAFLOW_BATCH_JOB_NAME_PREFIX=disaster-batch-job
DATAFLOW_SERVICE_ACCOUNT=your-dataflow-sa@your-project-id.iam.gserviceaccount.com

# Vertex AI
VERTEX_AI_PIPELINE_ROOT=gs://your-project-id-vertex-pipelines
VERTEX_AI_SERVICE_ACCOUNT=your-vertex-ai-sa@your-project-id.iam.gserviceaccount.com

# Cloud Run (Webapp)
WEBAPP_SERVICE_NAME=disaster-monitor-webapp

# Add other service-specific variables as needed
# E.g., API keys for external data sources (ensure these are managed securely, e.g., via Secret Manager)
# EXTERNAL_WEATHER_API_KEY=your_api_key
# SOCIAL_MEDIA_API_TOKEN=your_token
```
Ensure sensitive values like API keys are managed using Google Secret Manager and referenced in configurations, not hardcoded.

## Contributing

We welcome contributions to the Real-Time Disaster Alert & Impact Assessment System! Please see `CONTRIBUTING.md` (you may need to create this file if it doesn't exist) for guidelines on how to:

*   Report bugs and request features.
*   Set up your development environment.
*   Submit pull requests.
*   Follow coding standards and testing procedures.

## License

This project is licensed under the Apache License 2.0. You may need to create a `LICENSE` file with the contents of the Apache License 2.0.