# Deploy Data Ingestion Script (PowerShell)
# This script deploys the Cloud Function for data ingestion

Write-Host "Deploying Data Ingestion Cloud Function..."

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

# Navigate to data-ingestion directory
Set-Location ..\data-ingestion

# Deploy Cloud Function
Write-Host "Deploying Cloud Function..."
$region = $env:GOOGLE_CLOUD_REGION
if (-not $region) { $region = "us-central1" }
$pubsubTopic = $env:PUBSUB_TOPIC
if (-not $pubsubTopic) { $pubsubTopic = "disaster-alerts" }
$usgsApi = $env:USGS_API_BASE_URL
if (-not $usgsApi) { $usgsApi = "https://earthquake.usgs.gov/earthquakes/feed/v1.0" }
$nasaApi = $env:NASA_EONET_API_BASE_URL
if (-not $nasaApi) { $nasaApi = "https://eonet.gsfc.nasa.gov/api/v3" }
$serviceAccount = $env:CLOUD_FUNCTION_SERVICE_ACCOUNT
if (-not $serviceAccount) { $serviceAccount = "cloud-function-sa@$($env:GOOGLE_CLOUD_PROJECT).iam.gserviceaccount.com" }

gcloud functions deploy disaster-data-ingestion `
    --gen2 `
    --runtime=python311 `
    --region=$region `
    --source=. `
    --entry-point=ingest_disaster_data `
    --trigger-topic=$pubsubTopic `
    --set-env-vars="GOOGLE_CLOUD_PROJECT=$($env:GOOGLE_CLOUD_PROJECT),PUBSUB_TOPIC=$pubsubTopic,USGS_API_BASE_URL=$usgsApi,NASA_EONET_API_BASE_URL=$nasaApi" `
    --service-account=$serviceAccount `
    --memory=512MB `
    --timeout=540s

# Create Cloud Scheduler job to trigger the function every 5 minutes
Write-Host "Creating Cloud Scheduler job..."
try {
    gcloud scheduler jobs create pubsub disaster-data-scheduler `
        --schedule="*/5 * * * *" `
        --topic=$pubsubTopic `
        --message-body="{}" `
        --location=$region `
        --description="Trigger disaster data ingestion every 5 minutes"
} catch {
    Write-Host "Warning: Scheduler job may already exist"
}

Write-Host "Data ingestion deployment complete!" 