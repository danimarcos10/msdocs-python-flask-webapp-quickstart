targetScope = 'resourceGroup'

// Key Vault deployment file for secure credential management

// Parameters
@description('Name of the environment')
param environmentName string = 'dev'

@description('Primary location for all resources')
param location string = resourceGroup().location

@description('Key Vault name')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

// Variables
var tags = {
  'azd-env-name': environmentName
}

// Azure Key Vault
module keyVault './modules/key-vault.bicep' = {
  name: 'keyVault'
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    servicePrincipalObjectId: '25d8d697-c4a2-479f-96e0-15593a830ae5'
    roleAssignments: []
    tags: tags
  }
}

// Outputs
output keyVaultName string = keyVault.outputs.name
output keyVaultResourceId string = keyVault.outputs.resourceId
output keyVaultUri string = keyVault.outputs.uri 
