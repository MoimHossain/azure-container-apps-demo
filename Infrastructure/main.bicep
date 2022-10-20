targetScope = 'resourceGroup'

param location string = resourceGroup().location
param logAnalyticsName string = 'xeniel-laworkspace'
param appInsightName string = 'xeniel-appInsights-01'
param acaEnvName string = 'xeniel-aca-environment'
param storageAccountName string = 'xenielstorageacc001'
param storageContainerName string = 'xeniels'
param storageQueueName string = 'xeniels'
param storageSecKeyName string = 'StorageKey'
param storageSecAccountName string = 'StorageAccountName'
param storageSecContainerName string = 'ContainerName'
param serviceBusNamespace string = 'xenielservicebus'
param serviceBusTopicName string = 'xeniel-tpic'
param serviceBusTopicSubName string = 'xeniel-tpic-frontend'
param signalRName string = 'xenielsignalr'

param keyvaultName string = 'xeniels-keyvault-alpha'
param uamiName string = 'xeniel-app-identity'
param signalRKeyName string = 'SignalRConnectionString'

param computerVisionAccountName string = 'xenielscomputvision'
param KV_CVAccountKyName string = 'ComputerVisionKey'
param KV_CVAccountEdnpointName string = 'ComputerVisionEdnpoint'

param containerRegistryName string = 'xenielscontainerregistry'

module uami 'modules/identity.bicep' = {
  name: uamiName
  params: {
    uamiName: uamiName
    location: location
  }
}

module containerRegistry  'modules/registry.bicep' = {
  name: containerRegistryName
  params: {
    location: location
    registryName: containerRegistryName
    skuName: 'Basic'
    userAssignedIdentityPrincipalId: uami.outputs.principalId
    adminUserEnabled: false
  }
}

// module keyvault 'modules/keyvault.bicep' = {
//   name: keyvaultName
//   params: {
//     keyVaultName: keyvaultName
//     objectId: uami.outputs.principalId
//     enabledForDeployment: false
//     enabledForDiskEncryption: false
//     enabledForTemplateDeployment: false
//     keysPermissions: [
//       'get'
//       'list'
//     ]
//     secretsPermissions: [
//       'get'
//       'list'
//     ]
//     location: location
//     skuName: 'standard'  
//   }
// }



// module computerVision 'modules/computerVision.bicep' = {
//   name: computerVisionAccountName
//   params: {
//     accountEndpointKeyVaultKey: KV_CVAccountEdnpointName
//     accountKyVaultKy: KV_CVAccountKyName
//     accountName: computerVisionAccountName
//     identityPrincipalId: uami.outputs.principalId
//     keyVaultName: keyvault.name
//     location: location
//   }
// }


// module serviceBus 'modules/service-bus.bicep' = {
//   name: 'xenielservicebus'  
//   params: {
//     serviceBusNamespace: serviceBusNamespace
//     serviceBusTopicName: serviceBusTopicName
//     serviceBusTopicSubName: serviceBusTopicSubName
//     location: location
//     identityPrincipalId: uami.outputs.principalId
//   }
// }

// module storageAccount 'modules/storageAccount.bicep' = {
//   name: storageAccountName
//   params: {
//     accountName: storageAccountName
//     containerName: storageContainerName
//     queueName: storageQueueName
//     location: location
//     identityPrincipalId: uami.outputs.principalId
//     keyVaultName: keyvault.name
//     storageSecKeyName: storageSecKeyName
//     storageSecAccountName: storageSecAccountName
//     storageSecContainerName: storageSecContainerName
//   }
// }

// var eventGridTopicName = '${storageAccountName}-${serviceBusTopicName}-topic'
// module eventgridTopicToServiceBus 'modules/eventGridServiceBus.bicep' = {
//   name: eventGridTopicName
//   dependsOn: [
//     serviceBus
//     storageAccount
//   ]
//   params: {
//     eventGridSystemTopicName: eventGridTopicName 
//     location: location
//     serviceBusNamespace: serviceBus.outputs.namespace
//     serviceBusTopicName: serviceBus.outputs.topicName
//     storageAccountName: storageAccount.outputs.accountName
//   }
// }


// module signalR 'modules/signalr.bicep' = {
//   name: signalRName
//   params: {
//     signalRName: signalRName
//     location: location
//     keyVaultName: keyvault.name
//     signalRKeyName: signalRKeyName
//   }
// }




// module logAnalytics 'modules/log-analytics.bicep' = {
//   name: logAnalyticsName
//   params: {
//     logAnalyticsName: logAnalyticsName
//     localtion: location
//   }
// }

// module appInsights 'modules/appInsights.bicep' = {
//   name: appInsightName
//   params: {
//     appInsightName: appInsightName
//     location: location
//     laWorkspaceId: logAnalytics.outputs.laWorkspaceId
//   }
// }

// module acaEnvironment 'modules/environment.bicep' = {
//   name: acaEnvName
//   params: {
//     appInsightKey: appInsights.outputs.InstrumentationKey
//     location: location
//     envrionmentName: acaEnvName
//     laWorkspaceName: logAnalyticsName
//   }
// }
