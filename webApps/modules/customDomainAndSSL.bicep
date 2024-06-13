param appServiceName string
param customDomainName string
param sslThumbprint string

resource appService 'Microsoft.Web/sites@2023-12-01' existing = {
  name: appServiceName
}

resource customHostName 'Microsoft.Web/sites/hostNameBindings@2023-12-01' = {
  parent: appService
  name: customDomainName
  properties: {
    siteName: appService.name
    customHostNameDnsRecordType: 'A'
    hostNameType: 'Verified'
    sslState: 'SniEnabled'
    thumbprint: sslThumbprint
  }
}
