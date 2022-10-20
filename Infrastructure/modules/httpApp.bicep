param containerAppName string
param location string = resourceGroup().location
param revisionSuffix string = uniqueString(resourceGroup().id)
param environmentName string 
param containerImage string
param containerPort int
param isExternalIngress bool
param containerRegistry string
param containerRegistryUsername string
param isPrivateRegistry bool
param enableIngress bool 
@secure()
param registryPassword string
param useManagedIdentityForImagePull bool = false
param minReplicas int = 0
param secrets array = []
param env array = []
@allowed([
  'Single'
  'Multiple'
])
param revisionMode string = 'Single'
param hasIdentity bool
param userAssignedIdentityName string

var sanitizedRevisionSuffix = substring(revisionSuffix, 0, 10)

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: userAssignedIdentityName
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environmentName
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: hasIdentity ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  } : null
  properties: {
    managedEnvironmentId: environment.id    
    configuration: {
      activeRevisionsMode: revisionMode
      secrets: secrets      
      registries: isPrivateRegistry ? [
        {
          server: containerRegistry
          identity: useManagedIdentityForImagePull ? uami.id : null
          username: useManagedIdentityForImagePull ? null : containerRegistryUsername
          passwordSecretRef: useManagedIdentityForImagePull ? null : registryPassword
        }
      ] : null
      ingress: enableIngress ? {
        external: isExternalIngress
        targetPort: containerPort
        transport: 'auto'
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      } : null
      dapr: {
        enabled: true
        appPort: containerPort
        appId: containerAppName
      }
    }
    template: {
      revisionSuffix: sanitizedRevisionSuffix
      containers: [
        {
          image: containerImage
          name: containerAppName
          env: env
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: 1
      }
    }
  }
}

output fqdn string = enableIngress ? containerApp.properties.configuration.ingress.fqdn : 'Ingress not enabled'
