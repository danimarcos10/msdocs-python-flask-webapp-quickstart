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

@description('Key Vault name')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('Container Registry Image Name')
param containerRegistryImageName string = 'webappsimple'

@description('Container Registry Image Version')
param containerRegistryImageVersion string = 'latest'

// Variables
var tags = {
  'azd-env-name': environmentName
}

var keyVaultSecretNameACRUsername = 'acr-username'
var keyVaultSecretNameACRPassword1 = 'acr-password1'
var keyVaultSecretNameACRPassword2 = 'acr-password2'

// Azure Key Vault
module keyVault './modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    roleAssignments: [
      {
        principalId: '7200f83e-ec45-4915-8c52-fb94147cfe5a'
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'ServicePrincipal'
      }
    ]
    tags: tags
  }
}

// Reference to Key Vault for getSecret function
resource keyVaultResource 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
  dependsOn: [
    keyVault
  ]
}

// Azure Container Registry
module containerRegistry './modules/container-registry.bicep' = {
  name: 'containerRegistry'
  dependsOn: [
    keyVault
  ]
  params: {
    name: containerRegistryName
    location: location
    acrAdminUserEnabled: true
    adminCredentialsKeyVaultResourceId: keyVault.outputs.resourceId
    adminCredentialsKeyVaultSecretUserName: keyVaultSecretNameACRUsername
    adminCredentialsKeyVaultSecretUserPassword1: keyVaultSecretNameACRPassword1
    adminCredentialsKeyVaultSecretUserPassword2: keyVaultSecretNameACRPassword2
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
  dependsOn: [
    containerRegistry
    keyVault
  ]
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
    }
    dockerRegistryServerUrl: 'https://${containerRegistryName}.azurecr.io'
    dockerRegistryServerUserName: keyVaultResource.getSecret(keyVaultSecretNameACRUsername)
    dockerRegistryServerPassword: keyVaultResource.getSecret(keyVaultSecretNameACRPassword1)
    tags: tags
  }
}

// Outputs
output containerRegistryName string = containerRegistry.outputs.name
output containerRegistryLoginServer string = containerRegistry.outputs.loginServer
output appServicePlanName string = appServicePlan.outputs.name
output webAppName string = webApp.outputs.name
output webAppUrl string = 'https://${webApp.outputs.defaultHostname}'
output keyVaultName string = keyVault.outputs.name
output keyVaultUri string = keyVault.outputs.uri

