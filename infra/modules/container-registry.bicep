@description('Name of the Container Registry')
param name string

@description('Location for the Container Registry')
param location string = resourceGroup().location

@description('Enable admin user for the Container Registry')
param acrAdminUserEnabled bool = true

@description('Tags to apply to the Container Registry')
param tags object = {}

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

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
output resourceId string = containerRegistry.id
output adminCredentials object = {
  username: containerRegistry.listCredentials().username
  password: containerRegistry.listCredentials().passwords[0].value
} 
