param accountName string
param location string
param containerName string
param queueName string
param keyVaultName string
param storageSecKeyName string
param identityPrincipalId string
param storageSecAccountName string
param storageSecContainerName string

//storage account
resource mainstorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: accountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

module storageContainerNameSecret 'kvSecret.bicep' = {
  name: '${mainstorage.name}-deploy-containerName'
  params: {
    keyVaultName: keyVaultName
    secretName: storageSecContainerName
    secretValue: containerName
  }
}

module storageAccountNameSecret 'kvSecret.bicep' = {
  name: '${mainstorage.name}-deploy-accountName'
  params: {
    keyVaultName: keyVaultName
    secretName: storageSecAccountName
    secretValue: mainstorage.name
  }
}

module storageKeySecret 'kvSecret.bicep' = {
  name: '${mainstorage.name}-deploy-secrets'
  params: {
    keyVaultName: keyVaultName
    secretName: storageSecKeyName
    secretValue: mainstorage.listKeys().keys[0].value
  }
}

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var roleDefinitionId  = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {  
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: mainstorage
  name: guid('${accountName}-identity-contributor')
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: identityPrincipalId    
  }
}

resource defaultFileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: mainstorage
  name: 'default'
}

resource defaultQueueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  parent: mainstorage
  name: 'default'
}

resource defaultTableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  parent: mainstorage
  name: 'default'
}

resource defaultBlobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: mainstorage
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  parent: defaultBlobService
  name: containerName
}


resource storageQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2022-05-01' = {
  parent: defaultQueueService
  name: queueName
}


// module eventGridTopic  'eventGridTopic.bicep' = {
//   name: '${mainstorage.name}-topic'
//   params: {
//     eventGridSystemTopicName: '${mainstorage.name}-topic'
//     location: location
//     storageAccountName: mainstorage.name
//     storageQueueName: queueName
//   }
// }


output accountName string = mainstorage.name
