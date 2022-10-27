param eventGridSystemTopicName string
param location string
param storageAccountName string
param serviceBusTopicName string
param serviceBusNamespace string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' existing = { name: storageAccountName }
resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = { name: serviceBusNamespace }
resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' existing = { name: '${serviceBusNamespace}/${serviceBusTopicName}' }


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

resource roleAssignmentForSystemIdentity 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: serviceBus
  name: guid('${eventGridSystemTopicName}-managedidentity')
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: eventGridSystemTopic.identity.principalId    
  }
}


resource eventgridTopicSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  name: '${eventGridSystemTopic.name}/xenielsubscription'
  properties: {
    eventDeliverySchema: 'CloudEventSchemaV1_0'
    destination: {
      endpointType: 'ServiceBusTopic'
      properties: {
        resourceId: topic.id
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
