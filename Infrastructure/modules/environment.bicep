@description('Name of the Azure Container App environment')
param envrionmentName string
param location string = resourceGroup().location
@secure()
param appInsightKey string

param laWorkspaceName string


resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: laWorkspaceName
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: envrionmentName
  location: location
  properties: {
    daprAIInstrumentationKey: appInsightKey //appInsights.properties.InstrumentationKey

    appLogsConfiguration: {      
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId 
        sharedKey: logAnalytics.listKeys().primarySharedKey 
      }
    }
  }
}


