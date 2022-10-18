param componentName string
param acaEnvName string
param storageAccountName string
param queueName string
param storagekeySecKeyName string
param appScopes array
//@secure() 
//param secretStoreName string

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = { name: acaEnvName }
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {  name: storageAccountName }

resource storageQueueBindingComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = {
  name: componentName
  parent: environment
  properties: {
    componentType: 'bindings.azure.storagequeues'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '59s'    
    // Secret store backed by Azure Key vault - didn't work for Dapr component
    //secretStoreComponent: secretStoreName
    metadata: [
      {
        name: 'accountName'
        value: storageAccountName
      }
      // Managed Identity - Didn't work
      // {
      //   name: 'azureClientId'
      //   value: managedIdentityClientId
      // }
      {
        name: 'accountKey'
        secretRef: storagekeySecKeyName
      }
      {
        name: 'queueName'
        value: queueName
      }
      {
        name: 'ttlInSeconds'
        value: '60'
      }
      {
        name: 'decodeBase64'
        value: 'true'
      }
    ]
    secrets: [
      {
        name: storagekeySecKeyName
        value: storageAccount.listKeys().keys[0].value
      }
    ]
    scopes: appScopes
  }
}
