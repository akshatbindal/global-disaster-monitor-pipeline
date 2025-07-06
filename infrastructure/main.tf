terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "pubsub.googleapis.com",
    "dataflow.googleapis.com",
    "bigquery.googleapis.com",
    "aiplatform.googleapis.com",
    "run.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "storage.googleapis.com"
  ])
  
  service = each.value
  disable_dependent_services = false
}

# Create Pub/Sub topic
resource "google_pubsub_topic" "disaster_alerts" {
  name = var.pubsub_topic
  depends_on = [google_project_service.required_apis]
}

# Create Pub/Sub subscription
resource "google_pubsub_subscription" "disaster_alerts_sub" {
  name  = var.pubsub_subscription
  topic = google_pubsub_topic.disaster_alerts.name
}

# Create BigQuery dataset
resource "google_bigquery_dataset" "disaster_monitor" {
  dataset_id  = var.bigquery_dataset
  description = "Dataset for disaster monitoring data"
  location    = var.region
}

# Create BigQuery table for disaster events
resource "google_bigquery_table" "disaster_events" {
  dataset_id = google_bigquery_dataset.disaster_monitor.dataset_id
  table_id   = var.bigquery_table_events

  schema = file("${path.module}/schemas/disaster_events.json")

  deletion_protection = false
}

# Create BigQuery table for demographics
resource "google_bigquery_table" "demographics" {
  dataset_id = google_bigquery_dataset.disaster_monitor.dataset_id
  table_id   = var.bigquery_table_demographics

  schema = file("${path.module}/schemas/demographics.json")

  deletion_protection = false
}

# Create Cloud Storage bucket for Dataflow
resource "google_storage_bucket" "dataflow_bucket" {
  name          = "${var.project_id}-dataflow-${random_id.bucket_suffix.hex}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create service account for Dataflow
resource "google_service_account" "dataflow_sa" {
  account_id   = "dataflow-sa"
  display_name = "Dataflow Service Account"
}

# Grant Dataflow service account permissions
resource "google_project_iam_member" "dataflow_worker" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

resource "google_project_iam_member" "bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

resource "google_project_iam_member" "pubsub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

# Create service account for Cloud Functions
resource "google_service_account" "cloud_function_sa" {
  account_id   = "cloud-function-sa"
  display_name = "Cloud Function Service Account"
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_function_sa.email}"
} 