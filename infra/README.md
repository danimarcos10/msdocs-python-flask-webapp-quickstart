# Infrastructure as Code - Flask Web App

This directory contains the Bicep templates and modules for deploying the Flask web application infrastructure to Azure.

## Architecture

The infrastructure consists of:

1. **Azure Container Registry (ACR)** - Stores the Docker images
2. **Azure App Service Plan (Linux)** - Hosts the web application
3. **Azure Web App** - Runs the containerized Flask application

## Files Structure

```
infra/
├── main.bicep                 # Main orchestrator template
├── main.parameters.json       # Parameters file
├── modules/
│   ├── container-registry.bicep   # ACR module
│   ├── app-service-plan.bicep     # App Service Plan module
│   └── web-app.bicep              # Web App module
└── README.md                  # This file
```

## Modules

### Container Registry Module
- **File**: `modules/container-registry.bicep`
- **Purpose**: Creates an Azure Container Registry with admin user enabled
- **Parameters**: name, location, acrAdminUserEnabled, tags

### App Service Plan Module
- **File**: `modules/app-service-plan.bicep`
- **Purpose**: Creates a Linux App Service Plan with Basic B1 SKU
- **Parameters**: name, location, sku, kind, reserved, tags

### Web App Module
- **File**: `modules/web-app.bicep`
- **Purpose**: Creates a Web App configured for Docker containers
- **Parameters**: name, location, kind, serverFarmResourceId, siteConfig, appSettingsKeyValuePairs, tags

## Deployment

### Prerequisites
1. Azure CLI installed and configured
2. Bicep CLI installed
3. Access to the `aguadamillas_students_1` resource group

### Manual Deployment
```bash
# Deploy the infrastructure
az deployment group create \
  --resource-group aguadamillas_students_1 \
  --template-file main.bicep \
  --parameters @main.parameters.json
```

### GitHub Actions Deployment
The infrastructure is automatically deployed via GitHub Actions when changes are pushed to the `infra/` directory.

**Workflow**: `.github/workflows/deploy-infrastructure.yml`

**Required Secrets**:
- `AZURE_CREDENTIALS` - Service principal credentials
- `AZURE_SUBSCRIPTION_ID` - Azure subscription ID

## Configuration

The Web App is configured with the following settings:
- **Docker Image**: `{containerRegistryName}.azurecr.io/webappsimple:latest`
- **Container Port**: 50505 (internal)
- **Registry Authentication**: Admin credentials from ACR

## Outputs

After deployment, the following outputs are available:
- `containerRegistryName` - Name of the created ACR
- `containerRegistryLoginServer` - Login server URL for ACR
- `appServicePlanName` - Name of the App Service Plan
- `webAppName` - Name of the Web App
- `webAppUrl` - Public URL of the deployed web application 