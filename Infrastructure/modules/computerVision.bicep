@description('Name of the Azure Computer vision')
param accountName string
param location string = resourceGroup().location
param keyVaultName string
param identityPrincipalId string
param accountEndpointKeyVaultKey string
param accountKyVaultKy string 

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = { name: keyVaultName }


resource computerVisionAccount 'Microsoft.CognitiveServices/accounts@2022-10-01' = {
  name: accountName
  location: location
  sku: {
    name: 'F0'
  }
  kind: 'ComputerVision'
  properties: {
    customSubDomainName: accountName
    networkAcls: {
      defaultAction: 'Allow'
      virtualNetworkRules: [ ]
      ipRules: []
    }
    publicNetworkAccess: 'Enabled'
  }
}

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var roleDefinitionId  = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {  
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: computerVisionAccount
  name: guid('${accountName}-identity-contributor')
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: identityPrincipalId    
  }
}


module computerVisionKey 'kvSecret.bicep' = {
  name: '${accountName}${accountKyVaultKy}-deploy-secrets'
  params: {
    keyVaultName: keyVault.name
    secretName: accountKyVaultKy
    secretValue: computerVisionAccount.listKeys().key1
  }
}

module computerVisionEndpoint 'kvSecret.bicep' = {
  name: '${accountName}${accountEndpointKeyVaultKey}-deploy-secrets'
  params: {
    keyVaultName: keyVault.name
    secretName: accountEndpointKeyVaultKey
    secretValue: computerVisionAccount.properties.endpoint
  }
}
