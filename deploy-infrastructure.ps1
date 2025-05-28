# Deploy Infrastructure Script
# This script deploys the Flask web app infrastructure to Azure

param(
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "BCSAI2024-DEVOPS-STUDENTS-A-DEV",
    
    [Parameter(Mandatory=$false)]
    [string]$Location = "westeurope"
)

Write-Host "Starting infrastructure deployment..." -ForegroundColor Green

# Check if Azure CLI is installed
try {
    az --version | Out-Null
    Write-Host "✓ Azure CLI is installed" -ForegroundColor Green
} catch {
    Write-Error "Azure CLI is not installed. Please install it first."
    exit 1
}

# Check if logged in to Azure
$account = az account show 2>$null
if (-not $account) {
    Write-Host "Please log in to Azure first:" -ForegroundColor Yellow
    Write-Host "az login" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Logged in to Azure" -ForegroundColor Green

# Validate Bicep template
Write-Host "Validating Bicep template..." -ForegroundColor Yellow
try {
    az deployment group validate `
        --resource-group $ResourceGroupName `
        --template-file "infra/main.bicep" `
        --parameters "@infra/main.parameters.json"
    
    Write-Host "✓ Bicep template validation successful" -ForegroundColor Green
} catch {
    Write-Error "Bicep template validation failed. Please check your template."
    exit 1
}

# Deploy infrastructure
Write-Host "Deploying infrastructure to resource group: $ResourceGroupName" -ForegroundColor Yellow
try {
    $deployment = az deployment group create `
        --resource-group $ResourceGroupName `
        --template-file "infra/main.bicep" `
        --parameters "@infra/main.parameters.json" `
        --output json | ConvertFrom-Json
    
    Write-Host "✓ Infrastructure deployment successful!" -ForegroundColor Green
    
    # Display outputs
    Write-Host "`nDeployment Outputs:" -ForegroundColor Cyan
    Write-Host "Container Registry: $($deployment.properties.outputs.containerRegistryName.value)" -ForegroundColor White
    Write-Host "Container Registry Login Server: $($deployment.properties.outputs.containerRegistryLoginServer.value)" -ForegroundColor White
    Write-Host "App Service Plan: $($deployment.properties.outputs.appServicePlanName.value)" -ForegroundColor White
    Write-Host "Web App Name: $($deployment.properties.outputs.webAppName.value)" -ForegroundColor White
    Write-Host "Web App URL: $($deployment.properties.outputs.webAppUrl.value)" -ForegroundColor White
    
} catch {
    Write-Error "Infrastructure deployment failed. Please check the error messages above."
    exit 1
}

Write-Host "`n🎉 Infrastructure deployment completed successfully!" -ForegroundColor Green
Write-Host "You can now proceed to deploy your application to the created resources." -ForegroundColor Yellow 