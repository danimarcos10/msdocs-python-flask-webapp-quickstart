#!/bin/bash

# Deploy Infrastructure Script
# This script deploys the Flask web app infrastructure to Azure

RESOURCE_GROUP_NAME="BCSAI2024-DEVOPS-STUDENTS-A-DEV"
LOCATION="westeurope"

echo "🚀 Starting infrastructure deployment..."

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI is not installed. Please install it first."
    exit 1
fi
echo "✅ Azure CLI is installed"

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo "⚠️  Please log in to Azure first:"
    echo "az login"
    exit 1
fi
echo "✅ Logged in to Azure"

# Validate Bicep template
echo "🔍 Validating Bicep template..."
if az deployment group validate \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "infra/main.bicep" \
    --parameters "@infra/main.parameters.json" > /dev/null; then
    echo "✅ Bicep template validation successful"
else
    echo "❌ Bicep template validation failed. Please check your template."
    exit 1
fi

# Deploy infrastructure
echo "🏗️  Deploying infrastructure to resource group: $RESOURCE_GROUP_NAME"
DEPLOYMENT_OUTPUT=$(az deployment group create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --template-file "infra/main.bicep" \
    --parameters "@infra/main.parameters.json" \
    --output json)

if [ $? -eq 0 ]; then
    echo "✅ Infrastructure deployment successful!"
    
    # Extract and display outputs
    echo ""
    echo "📋 Deployment Outputs:"
    echo "Container Registry: $(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.containerRegistryName.value')"
    echo "Container Registry Login Server: $(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.containerRegistryLoginServer.value')"
    echo "App Service Plan: $(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.appServicePlanName.value')"
    echo "Web App Name: $(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.webAppName.value')"
    echo "Web App URL: $(echo "$DEPLOYMENT_OUTPUT" | jq -r '.properties.outputs.webAppUrl.value')"
    
    echo ""
    echo "🎉 Infrastructure deployment completed successfully!"
    echo "You can now proceed to deploy your application to the created resources."
else
    echo "❌ Infrastructure deployment failed. Please check the error messages above."
    exit 1
fi 