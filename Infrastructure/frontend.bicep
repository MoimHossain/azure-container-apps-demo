targetScope = 'resourceGroup'

param tagName string
param containerRegistryName string = 'xenielscontainerregistry'
param location string = resourceGroup().location
param acaEnvName string = 'xeniel-aca-environment'

param uamiName string = 'xeniel-app-identity'
var appNameFrontend = 'xeniel-frontend'
resource acaEnvironment 'Microsoft.App/managedEnvironments@2022-03-01'  existing = {   name: acaEnvName }
resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = { name: uamiName }

var revisionSUffix = substring(tagName, 0, 10)

module frontendApp 'modules/httpApp.bicep' = {
  name: appNameFrontend
  params: {    
    location: location
    containerAppName: appNameFrontend
    environmentName: acaEnvironment.name    
    revisionMode: 'Multiple'    
    trafficDistribution: [         
      {           
          revisionName: 'PREV'
          weight: 80
      }
      {
          revisionName: 'NEXT'
          label: 'latest'
          weight: 20
      }
    ]
    revisionSuffix: revisionSUffix
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
