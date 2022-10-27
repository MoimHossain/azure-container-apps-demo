param componentName string
param acaEnvName string
param signalRName string
param signalRHubName string
//param managedIdentityClientId string
param appScopes array

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = { name: acaEnvName }
resource signalR 'Microsoft.SignalRService/SignalR@2018-03-01-preview' existing = { name: signalRName }

var signalRSecretKeyName = 'signalr-connection-string'

resource storageQueueBindingComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: componentName
  parent: environment
  properties: {
    componentType: 'bindings.azure.signalr'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'    
    metadata: [
      {
        name: 'connectionString'
        secretRef: signalRSecretKeyName
        // Managed identity doesn't work yet
        //value: 'Endpoint=https://${signalRName}.service.signalr.net;AuthType=azure.msi;ClientId=${managedIdentityClientId};Version=1.0;'
      }
      {
        name: 'hub'
        value: signalRHubName
      }
    ]
    secrets: [
      {
        name: signalRSecretKeyName
        value: signalR.listKeys().primaryConnectionString
      }
    ]
    scopes: appScopes
  }
}
