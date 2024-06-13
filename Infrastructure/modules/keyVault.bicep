param location string
param tags object
param keyVaultName string
param appGatewayIdentity string

var skuName = 'standard'
var skuFamily = 'A'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  location: location
  name: keyVaultName
  tags: tags
  properties: {
    sku: {
      name: skuName
      family: skuFamily
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: appGatewayIdentity
        permissions: {
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: 'fee67ab1-9cfc-4844-9cd5-a571edf245d5'
        permissions: {
          secrets: [
            'get'
          ]
          certificates: [
            'get'
          ]
        }
      }
    ]
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    createMode: 'default'
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
  }
}

output name string = keyVault.name
