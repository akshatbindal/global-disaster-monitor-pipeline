# Deploy ML Model Script (PowerShell)
# This script trains and deploys the ML model to Vertex AI

Write-Host "Deploying ML Model to Vertex AI..."

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

# Navigate to ML model directory
Set-Location ..\ml-model

# Install dependencies
Write-Host "Installing dependencies..."
pip install -r requirements.txt

# Set environment variable to deploy to Vertex AI
[System.Environment]::SetEnvironmentVariable('DEPLOY_TO_VERTEX_AI', 'true')

# Train and deploy the model
Write-Host "Training and deploying model..."
python train_model.py

# Get the endpoint name from the file
if (Test-Path "endpoint_name.txt") {
    $endpointName = Get-Content "endpoint_name.txt" | Select-Object -First 1
    Write-Host "Model deployed to endpoint: $endpointName"
    
    # Update environment file with endpoint name
    Write-Host "Updating environment variables..."
    (Get-Content "..\.env") -replace "VERTEX_AI_ENDPOINT_NAME=.*", "VERTEX_AI_ENDPOINT_NAME=$endpointName" | Set-Content "..\.env"
    
    Write-Host "ML model deployment complete!"
    Write-Host "Endpoint: $endpointName"
} else {
    Write-Host "Warning: Endpoint name not found. Model may not have been deployed."
} 