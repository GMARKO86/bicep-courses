param location string = resourceGroup().location
param namePrefix string = 'gm'

var storageAccountName = '${namePrefix}${uniqueString(resourceGroup().id)}'
var storageAccountSKU = 'Standard_RAGRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSKU
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

output storageAccountId string = storageAccount.id
