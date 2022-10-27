param componentName string
param acaEnvName string
param serviceBusEndpoint string
param managedIdentityClientId string
param appScopes array

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: acaEnvName
}

resource storageQueueBindingComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: componentName
  parent: environment
  properties: {
    componentType: 'pubsub.azure.servicebus'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'    
    metadata: [
      {
        name: 'namespaceName'
        // NOTE: Dapr expects just the domain name.
        value: replace(replace(serviceBusEndpoint, 'https://', ''), ':443/', '')
      }
      {
        name: 'azureClientId'
        value: managedIdentityClientId
      }
      {
        name: 'timeoutInSec'
        value: '60'
      }
    ]
    scopes: appScopes
  }
}
