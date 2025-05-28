@description('Name of the App Service Plan')
param name string

@description('Location for the App Service Plan')
param location string = resourceGroup().location

@description('SKU configuration for the App Service Plan')
param sku object = {
  capacity: 1
  family: 'B'
  name: 'B1'
  size: 'B1'
  tier: 'Basic'
}

@description('Kind of App Service Plan')
param kind string = 'Linux'

@description('Reserved for Linux')
param reserved bool = true

@description('Tags to apply to the App Service Plan')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    reserved: reserved
  }
  sku: sku
}

output name string = appServicePlan.name
output resourceId string = appServicePlan.id 
