@description('Name of the Azure Container registry')
param registryName string
param location string = resourceGroup().location
param adminUserEnabled bool = false
param skuName string = 'Basic'
param userAssignedIdentityPrincipalId string = ''

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: skuName
  }
  properties: {
    adminUserEnabled: adminUserEnabled
  }
}


@description('This is the built-in AcrPull role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var acrPullRoleDefinitionId  = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {  
  name: acrPullRoleDefinitionId
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.name, 'acr-pull')
  properties: {
    roleDefinitionId: acrPullRoleDefinition.id
    principalId: userAssignedIdentityPrincipalId
  }
}


@description('This is the built-in AcrPull role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles')
var acrPushRoleDefinitionId  = '8311e382-0749-4cb8-b61a-304f252e45ec'

resource acrPushRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {  
  name: acrPushRoleDefinitionId
}

resource acrPushRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.name, 'acr-push')
  properties: {
    roleDefinitionId: acrPushRoleDefinition.id
    principalId: userAssignedIdentityPrincipalId
  }
}
