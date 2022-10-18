param componentName string
param acaEnvName string
param keyVaultName string
param managedIdentityClientId string
param appScopes array

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: acaEnvName
}

resource kvSecretStoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-03-01' = {
  name: componentName
  parent: environment
  properties: {
    componentType: 'secretstores.azure.keyvault'
    version: 'v1'
    ignoreErrors: false
    initTimeout: '5s'    
    metadata: [
      {
        name: 'vaultName'
        value: keyVaultName
      }
      {
        name: 'azureClientId'
        value: managedIdentityClientId
      }
    ]
    scopes: appScopes
  }
}
