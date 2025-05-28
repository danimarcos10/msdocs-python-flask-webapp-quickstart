@description('Name of the Container Registry')
param name string

@description('Location for the Container Registry')
param location string = resourceGroup().location

@description('Enable admin user for the Container Registry')
param acrAdminUserEnabled bool = true

@description('Tags to apply to the Container Registry')
param tags object = {}

@description('Resource ID of the Key Vault to store admin credentials')
param adminCredentialsKeyVaultResourceId string

@description('Name of the Key Vault secret for admin username')
@secure()
param adminCredentialsKeyVaultSecretUserName string

@description('Name of the Key Vault secret for admin password 1')
@secure()
param adminCredentialsKeyVaultSecretUserPassword1 string

@description('Name of the Key Vault secret for admin password 2')
@secure()
param adminCredentialsKeyVaultSecretUserPassword2 string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

// Reference to existing Key Vault
resource adminCredentialsKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: last(split(adminCredentialsKeyVaultResourceId, '/'))
}

// Store ACR admin username in Key Vault
resource secretAdminUserName 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserName
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

// Store ACR admin password 1 in Key Vault
resource secretAdminPassword1 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword1
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

// Store ACR admin password 2 in Key Vault
resource secretAdminPassword2 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: adminCredentialsKeyVaultSecretUserPassword2
  parent: adminCredentialsKeyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
output resourceId string = containerRegistry.id 
