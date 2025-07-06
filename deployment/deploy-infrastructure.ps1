# Deploy Infrastructure Script (PowerShell)
# This script deploys the Google Cloud infrastructure using Terraform

Write-Host "Deploying Infrastructure..."

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

# Navigate to infrastructure directory
Set-Location infrastructure

# Initialize Terraform
Write-Host "Initializing Terraform..."
terraform init

# Plan the deployment
Write-Host "Planning deployment..."
terraform plan `
    -var="project_id=$($env:GOOGLE_CLOUD_PROJECT)" `
    -var="region=$($env:GOOGLE_CLOUD_REGION -or 'us-central1')" `
    -out=tfplan

# Apply the deployment
Write-Host "Applying infrastructure changes..."
terraform apply tfplan

# Get outputs
Write-Host "Infrastructure outputs:"
terraform output

# Save important values
$bucketName = terraform output -raw dataflow_bucket_name
$dataflowSaEmail = terraform output -raw dataflow_service_account_email

Write-Host "Infrastructure deployed successfully!"
Write-Host "Dataflow bucket: $bucketName"
Write-Host "Dataflow service account: $dataflowSaEmail"

# Update environment file with new values
Write-Host "Updating environment variables..."
$envContent = Get-Content "..\.env"
$envContent = $envContent -replace "DATAFLOW_TEMP_LOCATION=.*", "DATAFLOW_TEMP_LOCATION=gs://$bucketName/temp"
$envContent = $envContent -replace "DATAFLOW_STAGING_LOCATION=.*", "DATAFLOW_STAGING_LOCATION=gs://$bucketName/staging"
$envContent = $envContent -replace "DATAFLOW_SERVICE_ACCOUNT=.*", "DATAFLOW_SERVICE_ACCOUNT=$dataflowSaEmail"
$envContent | Set-Content "..\.env"

Write-Host "Infrastructure deployment complete!" 