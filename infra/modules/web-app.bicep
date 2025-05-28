@description('Name of the Web App')
param name string

@description('Location for the Web App')
param location string = resourceGroup().location

@description('Kind of Web App')
param kind string = 'app'

@description('Resource ID of the App Service Plan')
param serverFarmResourceId string

@description('Site configuration')
param siteConfig object

@description('App settings as key-value pairs')
param appSettingsKeyValuePairs object

@description('Tags to apply to the Web App')
param tags object = {}

var appSettings = [for key in items(appSettingsKeyValuePairs): {
  name: key.key
  value: key.value
}]

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: {
    serverFarmId: serverFarmResourceId
    siteConfig: union(siteConfig, {
      appSettings: appSettings
    })
  }
}

output name string = webApp.name
output resourceId string = webApp.id
output defaultHostname string = webApp.properties.defaultHostName 
