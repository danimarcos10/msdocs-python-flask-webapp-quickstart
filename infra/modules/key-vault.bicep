@description('Required. The name of the Key Vault.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Enable vault for deployment.')
param enableVaultForDeployment bool = true

@description('Optional. Array of role assignment objects that contain the roleDefinitionIdOrName and principalId to define RBAC role assignments on this resource.')
param roleAssignments array = []

@description('Optional. Tags of the resource.')
param tags object = {}

@description('Required. Object ID of the service principal that needs access to Key Vault secrets.')
param servicePrincipalObjectId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: enableVaultForDeployment
    enabledForTemplateDeployment: enableVaultForDeployment
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    accessPolicies: []
  }
}

// Role assignments
resource keyVault_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleAssignment, index) in roleAssignments: {
  name: guid(keyVault.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  scope: keyVault
  properties: {
    roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    principalType: contains(roleAssignment, 'principalType') ? roleAssignment.principalType : null
  }
}]

// Additional role assignment for the service principal
resource servicePrincipalRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, servicePrincipalObjectId, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    roleDefinitionId: builtInRoleNames['Key Vault Secrets User']
    principalId: servicePrincipalObjectId
    principalType: 'ServicePrincipal'
  }
}

var builtInRoleNames = {
  'Key Vault Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
  'Key Vault Certificates Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a4417e6f-fecd-4de8-b567-7b0420556985')
  'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e147488a-f6f5-4113-8e2d-b22465e65bf6')
  'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424')
  'Key Vault Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '21090545-7ca7-4776-b22c-e363652d74d2')
  'Key Vault Secrets Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  'Key Vault Secrets User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
}

@description('The resource ID of the Key Vault.')
output resourceId string = keyVault.id

@description('The name of the Key Vault.')
output name string = keyVault.name

@description('The URI of the Key Vault.')
output uri string = keyVault.properties.vaultUri 
