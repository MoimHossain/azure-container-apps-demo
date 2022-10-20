targetScope = 'resourceGroup'
param tagName string
param containerRegistryName string = 'xenielscontainerregistry'
param location string = resourceGroup().location
param acaEnvName string = 'xeniel-aca-environment'
param keyvaultName string = 'xeniels-keyvault-alpha'
param uamiName string = 'xeniel-app-identity'
// param storageAccountName string = 'xenielstorageacc001'
// param storageQueueName string = 'xeniels'
// param storageSecKeyName string = 'StorageKey'
param serviceBusNamespace string = 'xenielservicebus'
param signalRName string = 'xenielsignalr'
param signalRHubName string = 'xeniels'

var appNameJobListener = 'xeniel-job-listener'
var appNameFrontend = 'xeniel-frontend'

var daprComponent_secretStore = 'xeniel-dapr-secret-store'
//var daprComponent_storageQueueBinding = 'xeniel-dapr-storage-queue-binding'
var daprComponent_serviceBusPubSub = 'xeniel-dapr-servicebus-pubsub'
var daprComponent_signalRBinding = 'xeniel-dapr-signalr-binding'


resource acaEnvironment 'Microsoft.App/managedEnvironments@2022-03-01'  existing = {   name: acaEnvName }
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = { name: uamiName }
resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-01-01-preview' existing = { name: serviceBusNamespace }


module daprSecretStore 'modules/dapr/kv-secret-store.bicep' = {
  name: daprComponent_secretStore
  params: {
    acaEnvName: acaEnvironment.name
    appScopes: [
      appNameJobListener
      appNameFrontend
    ]
    componentName: daprComponent_secretStore
    keyVaultName: keyvaultName
    managedIdentityClientId: uami.properties.clientId
  }
}

// module daprStorageQueueBinding 'modules/dapr/storage-queue-binding.bicep' = {
//   name: daprComponent_storageQueueBinding
//   params: {
//     acaEnvName: acaEnvironment.name
//     appScopes: [
//       testAppName
//     ]
//     componentName: daprComponent_storageQueueBinding 
//     storagekeySecKeyName: storageSecKeyName
//     // Managed identity - didn't work so far
//     //managedIdentityClientId: uami.properties.clientId
//     // Azure KeyVault based secret store - didn't work for queue binding
//     //secretStoreName: daprComponent_secretStore
//     storageAccountName: storageAccountName
//     queueName: storageQueueName
//   }
// }

module daprServiceBusPubsub 'modules/dapr/service-bus-pubsub.bicep' = {
  name: daprComponent_serviceBusPubSub
  params: {
    acaEnvName: acaEnvironment.name
    appScopes: [
      appNameJobListener
      appNameFrontend
    ]
    componentName: daprComponent_serviceBusPubSub
    managedIdentityClientId: uami.properties.clientId
    serviceBusEndpoint: serviceBus.properties.serviceBusEndpoint
  }
}

module daprSignalRBinding 'modules/dapr/signalR-binding.bicep' = {
  name: daprComponent_signalRBinding
  params: {
    acaEnvName: acaEnvironment.name
    appScopes: [
      appNameJobListener
      appNameFrontend
    ]
    componentName: daprComponent_signalRBinding 
    //managedIdentityClientId: uami.properties.clientId
    signalRHubName: signalRHubName
    signalRName: signalRName
  }
}


module jobListenerApp 'modules/httpApp.bicep' = {
  name: appNameJobListener
  params: {    
    location: location    
    containerAppName: appNameJobListener
    environmentName: acaEnvName
    hasIdentity: true
    userAssignedIdentityName: uami.name
    containerImage: '${containerRegistryName}.azurecr.io/job-listener:${tagName}'
    containerRegistry: '${containerRegistryName}.azurecr.io'
    isPrivateRegistry: true
    containerRegistryUsername: ''
    registryPassword: ''    
    useManagedIdentityForImagePull: true
    containerPort: 80
    enableIngress: true    
    isExternalIngress: false
    minReplicas: 1
  }
}

module frontendApp 'modules/httpApp.bicep' = {
  name: appNameFrontend
  params: {    
    location: location
    containerAppName: appNameFrontend
    environmentName: acaEnvName
    hasIdentity: true
    userAssignedIdentityName: uami.name
    containerImage: '${containerRegistryName}.azurecr.io/frontend:${tagName}'
    containerRegistry: '${containerRegistryName}.azurecr.io'
    isPrivateRegistry: true
    containerRegistryUsername: ''
    registryPassword: ''    
    useManagedIdentityForImagePull: true
    containerPort: 80
    enableIngress: true
    isExternalIngress: true
    minReplicas: 1
  }
}



// module garbageApp 'modules/httpApp.bicep' = {
//   name: 'xeniel-garbage'
//   params: {    
//     location: location
//     containerAppName: 'xeniel-garbage'
//     containerImage: 'xenielscontainerregistry.azurecr.io/samples/nginx:latest'
//     containerPort: 80
//     containerRegistry: 'xenielscontainerregistry.azurecr.io'
//     isPrivateRegistry: true
//     useManagedIdentityForImagePull: true
//     containerRegistryUsername: ''
//     registryPassword: ''

//     enableIngress: true
//     environmentName: acaEnvName
//     isExternalIngress: true    
    
//     minReplicas: 1    
//     hasIdentity: true
//     userAssignedIdentityName: uami.name
//   }
// }
