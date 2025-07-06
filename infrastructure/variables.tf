variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "us-central1"
}

variable "pubsub_topic" {
  description = "Pub/Sub topic name for disaster alerts"
  type        = string
  default     = "disaster-alerts"
}

variable "pubsub_subscription" {
  description = "Pub/Sub subscription name"
  type        = string
  default     = "disaster-alerts-sub"
}

variable "bigquery_dataset" {
  description = "BigQuery dataset name"
  type        = string
  default     = "disaster_monitor"
}

variable "bigquery_table_events" {
  description = "BigQuery table name for disaster events"
  type        = string
  default     = "disaster_events"
}

variable "bigquery_table_demographics" {
  description = "BigQuery table name for demographics"
  type        = string
  default     = "demographics"
} 