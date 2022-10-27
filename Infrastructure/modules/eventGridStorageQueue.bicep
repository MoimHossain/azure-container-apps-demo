param eventGridSystemTopicName string
param location string
param storageAccountName string
param storageQueueName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageAccountName
}

resource eventGridSystemTopic 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: eventGridSystemTopicName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: storageAccount.id
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var roleDefinitionId  = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {  
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: storageAccount
  name: guid(eventGridSystemTopicName)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: eventGridSystemTopic.identity.principalId    
  }
}


resource eventgridTopicSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: '${eventGridSystemTopic.name}/xenielsubscription'
  properties: {
    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'StorageQueue'
      properties: {
        resourceId: storageAccount.id
        queueName: storageQueueName
        queueMessageTimeToLiveInSeconds: 604800
      }
    }
    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
        'Microsoft.Storage.BlobDeleted'
      ]
      enableAdvancedFilteringOnArrays: true      
    }
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
