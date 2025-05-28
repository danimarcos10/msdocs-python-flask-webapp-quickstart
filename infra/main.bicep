targetScope = 'resourceGroup'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

// Parameters
@description('Name of the environment')
param environmentName string = 'dev'

@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Container Registry name')
param containerRegistryName string = 'acr${uniqueString(resourceGroup().id)}'

@description('App Service Plan name')
param appServicePlanName string = 'asp-${uniqueString(resourceGroup().id)}'

@description('Web App name')
param webAppName string = 'webapp-${uniqueString(resourceGroup().id)}'

@description('Container Registry Image Name')
param containerRegistryImageName string = 'webappsimple'

@description('Container Registry Image Version')
param containerRegistryImageVersion string = 'latest'

// Variables
var tags = {
  'azd-env-name': environmentName
}

// Azure Container Registry
module containerRegistry './modules/container-registry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    tags: tags
  }
}

// Azure Service Plan for Linux
module appServicePlan './modules/app-service-plan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: appServicePlanName
    location: location
    sku: {
      capacity: 1
      family: 'B'
      name: 'B1'
      size: 'B1'
      tier: 'Basic'
    }
    kind: 'Linux'
    reserved: true
    tags: tags
  }
}

// Azure Web App for Linux containers
module webApp './modules/web-app.bicep' = {
  name: 'webApp'
  params: {
    name: webAppName
    location: location
    kind: 'app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryName}.azurecr.io/${containerRegistryImageName}:${containerRegistryImageVersion}'
      appCommandLine: ''
    }
    appSettingsKeyValuePairs: {
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
      DOCKER_REGISTRY_SERVER_URL: 'https://${containerRegistryName}.azurecr.io'
      DOCKER_REGISTRY_SERVER_USERNAME: containerRegistry.outputs.adminCredentials.username
      DOCKER_REGISTRY_SERVER_PASSWORD: containerRegistry.outputs.adminCredentials.password
    }
    tags: tags
  }
}

// Outputs
output containerRegistryName string = containerRegistry.outputs.name
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output appServicePlanName string = appServicePlan.outputs.name
output webAppName string = webApp.outputs.name
output webAppUrl string = 'https://${webApp.outputs.defaultHostname}'

