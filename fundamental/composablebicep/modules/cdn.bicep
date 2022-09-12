@description('The host name (address) of the origin server.')
param originHostName string

@description('The naem of the CDN profile.')
param profileName string = 'cdn-${uniqueString(resourceGroup().id)}'

@description('The name of the CDN endpoint')
param endpointName string = 'endpoint-${uniqueString(resourceGroup().id)}'

@description('Indicates wheter the CDN endpoint requires HTTPS connections.')
param httpsOnly bool

var originName = 'my-origin'

resource cndProfile 'Microsoft.Cdn/profiles@2020-09-01' = {
  name: profileName
  location: 'global'
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource endpoint 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  parent: cndProfile
  name: endpointName
  location: 'global'
  properties: {
    originHostHeader: originHostName
    isHttpAllowed: !httpsOnly
    isHttpsAllowed: true
    queryStringCachingBehavior: 'IgnoreQueryString'
    contentTypesToCompress: [
      'text/plain'
      'text/html'
      'text/css'
      'application/x-javascript'
      'text/javascript'
    ]
    isCompressionEnabled: true
    origins: [
      {
        name: originName
        properties: {
          hostName: originHostName 
        }
      }
    ]
  }
}

@description('The host name of the CDN endpoint.')
output endpointHostName string = endpoint.properties.hostName
