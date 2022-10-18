
@description('Name of the Azure SignalR service')
param signalRName string
param location string = resourceGroup().location
param keyVaultName string 
param signalRKeyName string 

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}


resource signalR 'Microsoft.SignalRService/SignalR@2018-03-01-preview' = {
  name: signalRName
  location: location  
  sku: {
    name: 'Free_F1'
    tier: 'Free'
    size: 'F1'
    capacity: 1
  }
  properties: {

  }
}

module signalRSecret 'kvSecret.bicep' = {
  name: '${signalRName}-deploy-secrets'
  params: {
    keyVaultName: keyVault.name
    secretName: signalRKeyName
    secretValue: signalR.listKeys().primaryConnectionString
  }
}
