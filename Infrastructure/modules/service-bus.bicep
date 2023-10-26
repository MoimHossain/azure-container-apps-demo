@description('Name of the Azure service bus namespace')
param serviceBusNamespace string
param location string = resourceGroup().location
param serviceBusTopicName string 
param serviceBusTopicSubName string 
param identityPrincipalId string

resource sbNamespace 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' = {
  name: serviceBusNamespace
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    zoneRedundant: false
    minimumTlsVersion: '1.2'
  }
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-01-01-preview' = {
  parent: sbNamespace
  name: serviceBusTopicName
  properties: {
    maxMessageSizeInKilobytes: 256
    defaultMessageTimeToLive: 'P14D'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    status: 'Active'
    supportOrdering: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false 
  }
}


@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var contributorRoleDefinitionId  = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = { name: contributorRoleDefinitionId }

resource roleAssignmentContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: sbNamespace
  name: guid('${serviceBusNamespace}-userassignedidentity-contributor')  
  properties: {
    roleDefinitionId: contributorRoleDefinition.id
    principalId: identityPrincipalId    
  }
}

@description('This is the built-in Azure Service Bus Data Owner role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var azServiceBusDataOwnerRoleDefinitionId = '090c5cfd-751d-490a-894a-3ce6f1109419'
resource sbDataOwnerRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = { name: azServiceBusDataOwnerRoleDefinitionId }

resource roleAssignmentSbDataOwner 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: topic
  name: guid('${serviceBusNamespace}-userassignedidentity-sbowner')
  properties: {
    roleDefinitionId: sbDataOwnerRoleDefinition.id
    principalId: identityPrincipalId    
  }
}

resource authRules 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' = {
  parent: sbNamespace
  name: 'RootManageSharedAccessKey'
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'      
    ]
  }
}

resource networkRuleSets 'Microsoft.ServiceBus/namespaces/networkRuleSets@2022-01-01-preview' = {
  parent: sbNamespace
  name: 'default'
  properties: {
    publicNetworkAccess: 'Enabled'
    defaultAction: 'Allow'
    virtualNetworkRules: [
      
    ]
    ipRules: [
      
    ]
  }
}



resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-01-01-preview' = {
  parent: topic
  name: serviceBusTopicSubName
  properties: {
    isClientAffine: false
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'PT10S'
    deadLetteringOnMessageExpiration: false
    deadLetteringOnFilterEvaluationExceptions: true
    maxDeliveryCount: 3
    status: 'Active'
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}

resource rules 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2022-01-01-preview' = {
  name: '${serviceBusNamespace}/${serviceBusTopicName}/${serviceBusTopicSubName}/$Default'
  dependsOn: [
    subscription
  ]
  properties: {
    action: {}
    filterType: 'SqlFilter'
    sqlFilter: {
        sqlExpression: '1=1'
        compatibilityLevel: 20
    }
  }  
}


output namespace string = sbNamespace.name
output serviceBusEndpoint string = sbNamespace.properties.serviceBusEndpoint
output topicResourceId string = topic.id
output topicName string = serviceBusTopicName
