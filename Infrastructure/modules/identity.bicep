
@description('Specifies the name of the user assigned managed identity.')
param uamiName string
param location string = resourceGroup().location

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: uamiName
  location: location
}


output principalId string = uami.properties.principalId
output tenantId string = uami.properties.tenantId
output clientId string = uami.properties.clientId
