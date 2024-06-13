param location string
param uamiName string
param tags object

resource applicationGateWayUser 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
  tags: tags
}

output principalId string = applicationGateWayUser.properties.principalId
output resourceId string = applicationGateWayUser.id
