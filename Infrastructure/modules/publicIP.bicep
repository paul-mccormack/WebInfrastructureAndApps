param location string
param tags object
param appGatewayName string

var publicIpName = 'pip-${appGatewayName}'

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}
 output publicIpAddress string = publicIp.properties.ipAddress
