# Deploy Web Application Script (PowerShell)
# This script deploys the Streamlit web app to Cloud Run

Write-Host "Deploying Web Application to Cloud Run..."

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

# Navigate to webapp directory
Set-Location ..\webapp

# Build and push Docker image
Write-Host "Building Docker image..."
$imageName = "gcr.io/$($env:GOOGLE_CLOUD_PROJECT)/$($env:WEBAPP_SERVICE_NAME -or 'disaster-monitor-webapp')"
docker build -t $imageName .

Write-Host "Pushing Docker image..."
docker push $imageName

# Deploy to Cloud Run
Write-Host "Deploying to Cloud Run..."
gcloud run deploy $($env:WEBAPP_SERVICE_NAME -or 'disaster-monitor-webapp') `
    --image=$imageName `
    --platform=managed `
    --region=$($env:GOOGLE_CLOUD_REGION -or 'us-central1') `
    --allow-unauthenticated `
    --port=$($env:WEBAPP_PORT -or 8080) `
    --memory=2Gi `
    --cpu=1 `
    --max-instances=10 `
    --set-env-vars="GOOGLE_CLOUD_PROJECT=$($env:GOOGLE_CLOUD_PROJECT),BIGQUERY_DATASET=$($env:BIGQUERY_DATASET -or 'disaster_monitor'),BIGQUERY_TABLE_EVENTS=$($env:BIGQUERY_TABLE_EVENTS -or 'disaster_events')"

# Get the service URL
$serviceUrl = gcloud run services describe $($env:WEBAPP_SERVICE_NAME -or 'disaster-monitor-webapp') `
    --region=$($env:GOOGLE_CLOUD_REGION -or 'us-central1') `
    --format="value(status.url)"

Write-Host "Web application deployment complete!"
Write-Host "Service URL: $serviceUrl" 