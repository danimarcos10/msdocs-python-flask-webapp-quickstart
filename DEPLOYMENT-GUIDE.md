# Question 2 - Infrastructure Deployment Guide

This document provides a complete guide for deploying the Flask web application infrastructure to Azure using Bicep and GitHub workflows.

## 📋 Overview

We have successfully created:
- ✅ Bicep modules for Azure Container Registry, App Service Plan, and Web App
- ✅ Main orchestrator Bicep template (`main.bicep`)
- ✅ Parameters file (`main.parameters.json`)
- ✅ GitHub workflow for automated deployment
- ✅ Manual deployment scripts (PowerShell and Bash)

## 🏗️ Infrastructure Components

### 1. Azure Container Registry (ACR)
- **Module**: `infra/modules/container-registry.bicep`
- **Purpose**: Stores Docker images for the Flask application
- **Configuration**: Basic SKU with admin user enabled

### 2. Azure App Service Plan
- **Module**: `infra/modules/app-service-plan.bicep`
- **Purpose**: Provides compute resources for the web app
- **Configuration**: Linux-based, Basic B1 SKU

### 3. Azure Web App
- **Module**: `infra/modules/web-app.bicep`
- **Purpose**: Hosts the containerized Flask application
- **Configuration**: Configured for Docker containers with ACR integration

## 📁 File Structure

```
msdocs-python-flask-webapp-quickstart/
├── infra/
│   ├── main.bicep                      # Main orchestrator template
│   ├── main.parameters.json            # Parameters file
│   ├── modules/
│   │   ├── container-registry.bicep    # ACR module
│   │   ├── app-service-plan.bicep      # App Service Plan module
│   │   └── web-app.bicep               # Web App module
│   └── README.md                       # Infrastructure documentation
├── .github/
│   └── workflows/
│       └── deploy-infrastructure.yml   # GitHub Actions workflow
├── deploy-infrastructure.ps1           # PowerShell deployment script
├── deploy-infrastructure.sh            # Bash deployment script
└── DEPLOYMENT-GUIDE.md                 # This file
```

## 🚀 Deployment Options

### Option 1: GitHub Actions (Recommended)

1. **Setup GitHub Secrets**:
   ```
   AZURE_CREDENTIALS - Service principal credentials
   AZURE_SUBSCRIPTION_ID - Your Azure subscription ID
   ```

2. **Trigger Deployment**:
   - Push changes to the `main` branch
   - Or manually trigger via GitHub Actions UI

3. **Workflow File**: `.github/workflows/deploy-infrastructure.yml`

### Option 2: Manual Deployment (PowerShell)

```powershell
# Run from the project root directory
.\deploy-infrastructure.ps1 -ResourceGroupName "aguadamillas_students_1"
```

### Option 3: Manual Deployment (Bash)

```bash
# Make script executable
chmod +x deploy-infrastructure.sh

# Run from the project root directory
./deploy-infrastructure.sh
```

### Option 4: Azure CLI Direct

```bash
# Validate template
az deployment group validate \
  --resource-group aguadamillas_students_1 \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json

# Deploy infrastructure
az deployment group create \
  --resource-group aguadamillas_students_1 \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json
```

## ⚙️ Configuration Parameters

The deployment uses the following parameters (defined in `main.parameters.json`):

```json
{
  "environmentName": "dev",
  "location": "East US",
  "containerRegistryName": "acrflaskdemo2024",
  "appServicePlanName": "asp-flask-demo",
  "webAppName": "webapp-flask-demo-2024",
  "containerRegistryImageName": "webappsimple",
  "containerRegistryImageVersion": "latest"
}
```

## 📤 Deployment Outputs

After successful deployment, you'll receive:

- **Container Registry Name**: Name of the created ACR
- **Container Registry Login Server**: ACR login URL
- **App Service Plan Name**: Name of the App Service Plan
- **Web App Name**: Name of the Web App
- **Web App URL**: Public URL of the deployed application

## 🔐 Security Configuration

The Web App is configured with:
- **Docker Registry Authentication**: Uses ACR admin credentials
- **Container Settings**: Configured for Linux containers
- **App Settings**: Includes registry connection details

## ✅ Verification Steps

1. **Check Resource Group**: Verify all resources are created in `aguadamillas_students_1`
2. **Test ACR**: Ensure Container Registry is accessible
3. **Verify Web App**: Check that the Web App is running (may show default page until app is deployed)

## 🔗 GitHub Repository

Make sure to commit and push all files to your GitHub repository:

```bash
git add .
git commit -m "Add infrastructure as code with Bicep modules and GitHub workflow"
git push origin main
```

## 📋 Assignment Requirements Checklist

- ✅ Created Bicep modules for Azure Container Registry
- ✅ Created Bicep modules for Azure Service Plan (Linux)
- ✅ Created Bicep modules for Azure Web App (Linux containers)
- ✅ Created main.bicep orchestrator file
- ✅ Created parameters file
- ✅ Created GitHub workflow for deployment
- ✅ Configured deployment to `aguadamillas_students_1` resource group
- ✅ Used specified module parameters as required

## 🎯 Next Steps

After infrastructure deployment:
1. Build and push Docker image to ACR
2. Deploy application code to Web App
3. Configure application settings and environment variables
4. Set up monitoring and logging

---

**Note**: This completes Question 2 of the assignment. The infrastructure is ready for application deployment in the next questions. 