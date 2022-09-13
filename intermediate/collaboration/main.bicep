param location string = resourceGroup().location

@allowed([
  'NonProduction'
  'Production'
])
param environmentType string

var environmentConfigurationMap = {
  Production: {
    appServicePlanSkuName: 'S1'
    hostingPlanSkuCapacity: 2
    storageAccountSku: 'Standard_LRS'
    sqlServerDatabaseSku: 'S1'
  }
  NonProduction: {
    appServicePlanSkuName: 'F1'
    hostingPlanSkuCapacity: 1
    storageAccountSku: 'Standard_GRS'
    sqlServerDatabaseSku: 'Basic'
  }
}

param sqlAdministratorLogin string

@secure()
param sqlAdministratorLoginPassword string

param managedIdentityName string
param contributorRoleId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param appServiceAppName string = 'webSite${uniqueString(resourceGroup().id)}'

var roleAssignmentName = guid(contributorRoleId, resourceGroup().id)

var resourceNameSuffix = uniqueString(resourceGroup().id)
var appServicePlanName = 'appserviceplan${resourceNameSuffix}'
var sqlserverName = 'toywebsite${resourceNameSuffix}'
var storageAccountName = 'toywebsite${resourceNameSuffix}'
var storageAccountContainerNames = [ 'productspecs', 'productmanuals' ]
var databaseName = 'ToyCompanyWebsite'

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: storageAccountName
  location: 'eastus'
  sku: {
    name: environmentConfigurationMap[environmentType].storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }

  resource blobServices 'blobServices' existing = {
    name: 'default'
  }
}

resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for containerName in storageAccountContainerNames: {
  parent: storageAccount::blobServices
  name: containerName
}]

resource sqlserver 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: sqlserverName
  location: location
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
  }
}

resource sqlserverNameDatabaseName 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlserver
  name: databaseName
  location: location
  sku: {
    name: environmentConfigurationMap[environmentType].sqlServerDatabaseSku
  }
}

resource sqlserverNameAllowAllAzureIPs 'Microsoft.Sql/servers/firewallRules@2014-04-01' = {
  parent: sqlserver
  name: 'AllowAllAzureIPs'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: environmentConfigurationMap[environmentType].appServicePlanSkuName
    capacity: environmentConfigurationMap[environmentType].hostingPlanSkuCapacity
  }
}

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: AppInsightsWebSiteName.properties.InstrumentationKey
        }
        {
          name: 'StorageAccountConnectionString'
          value: storageAccount.properties.primaryEndpoints.
          // value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
      ]
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleId)
    principalId: managedIdentity.properties.principalId
  }
}

resource AppInsightsWebSiteName 'Microsoft.Insights/components@2018-05-01-preview' = {
  name: 'AppInsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}
