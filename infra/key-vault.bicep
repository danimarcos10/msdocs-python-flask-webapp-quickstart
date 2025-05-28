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

// Outputs
output keyVaultName string = keyVault.outputs.name
output keyVaultResourceId string = keyVault.outputs.resourceId
output keyVaultUri string = keyVault.outputs.uri 
