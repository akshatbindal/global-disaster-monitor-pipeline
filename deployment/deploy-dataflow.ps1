# Deploy Dataflow Pipeline Script (PowerShell)
# This script deploys the Apache Beam Dataflow pipeline

Write-Host "Deploying Dataflow Pipeline..."

# Load environment variables from .env
$envFile = "..\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | Where-Object { $_ -notmatch '^#' -and $_ -match '=' } | ForEach-Object {
        $parts = $_ -split '=', 2
        if ($parts.Count -eq 2) {
            [System.Environment]::SetEnvironmentVariable($parts[0].Trim(), $parts[1].Trim())
        }
    }
}

# Check if required variables are set
if (-not $env:GOOGLE_CLOUD_PROJECT) {
    Write-Host "Error: GOOGLE_CLOUD_PROJECT not set"
    exit 1
}

if (-not $env:GOOGLE_GEOCODING_API_KEY) {
    Write-Host "Warning: GOOGLE_GEOCODING_API_KEY not set. Geocoding will be disabled."
}

# Navigate to dataflow directory
Set-Location ..\dataflow-pipeline

# Create staging directories in Cloud Storage
Write-Host "Creating staging directories..."
gsutil mb -p $env:GOOGLE_CLOUD_PROJECT -c STANDARD -l $($env:GOOGLE_CLOUD_REGION -or 'us-central1') "gs://$($env:GOOGLE_CLOUD_PROJECT)-dataflow" 2>$null

gsutil -m cp -r requirements.txt "gs://$($env:GOOGLE_CLOUD_PROJECT)-dataflow/staging/" 2>$null

# Set environment variables for the pipeline
$env:PYTHONPATH = "$($env:PYTHONPATH):$(Get-Location)"

# Deploy the Dataflow job
Write-Host "Deploying Dataflow job..."
python pipeline.py `
    --project=$($env:GOOGLE_CLOUD_PROJECT) `
    --region=$($env:GOOGLE_CLOUD_REGION -or 'us-central1') `
    --temp_location="gs://$($env:GOOGLE_CLOUD_PROJECT)-dataflow/temp" `
    --staging_location="gs://$($env:GOOGLE_CLOUD_PROJECT)-dataflow/staging" `
    --service_account_email=$($env:DATAFLOW_SERVICE_ACCOUNT -or "dataflow-sa@$($env:GOOGLE_CLOUD_PROJECT).iam.gserviceaccount.com") `
    --runner=DataflowRunner `
    --job_name=$($env:DATAFLOW_JOB_NAME -or 'disaster-pipeline') `
    --streaming `
    --setup_file=./setup.py `
    --requirements_file=requirements.txt `
    --save_main_session `
    --environment_variables="GOOGLE_GEOCODING_API_KEY=$($env:GOOGLE_GEOCODING_API_KEY),GOOGLE_CLOUD_PROJECT=$($env:GOOGLE_CLOUD_PROJECT),BIGQUERY_DATASET=$($env:BIGQUERY_DATASET -or 'disaster_monitor'),PUBSUB_TOPIC=$($env:PUBSUB_TOPIC -or 'disaster-alerts'),BIGQUERY_TABLE_EVENTS=$($env:BIGQUERY_TABLE_EVENTS -or 'disaster_events'),VERTEX_AI_ENDPOINT_NAME=$($env:VERTEX_AI_ENDPOINT_NAME)"

Write-Host "Dataflow pipeline deployment complete!"
Write-Host "Monitor the job at: https://console.cloud.google.com/dataflow/jobs?project=$($env:GOOGLE_CLOUD_PROJECT)" 