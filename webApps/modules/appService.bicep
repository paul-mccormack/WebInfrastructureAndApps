param location string = resourceGroup().location
param appServiceName string = 'testwebapp-${uniqueString(resourceGroup().id)}'
param tags object
param keyVaultName string
param keyVaultSecretName string
param appServicePlanName string
param uamiName string
param vnetName string
var azureTenantId = tenant().tenantId



var configReferenceWindows = {
  metadata: [
    {
      name: 'CURRENT_STACK'
      value: 'dotnet'
    }
  ]
  netFrameworkVersion: 'v8.0'
  appSettings: [
    {
      name: 'TenantId'
      value: azureTenantId
    }
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: appServicePlanName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: uamiName
}


resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    siteConfig: configReferenceWindows
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

resource appServiceConfig 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: appService
  name: 'web'
  properties: {
    netFrameworkVersion: 'v8.0'
    publicNetworkAccess: 'Enabled'
    ipSecurityRestrictionsDefaultAction: 'Deny'
    ipSecurityRestrictions: [
      {
        vnetSubnetResourceId: '${vnet.id}/subnets/AGSubnet'
        action: 'Allow'
        tag: 'Default'
        priority: 200
        name: 'allowFromAppGateway'
        description: 'Traffic from App Gateway subnet Allowed'
      }
    ]
  }
}

resource certificate 'Microsoft.Web/certificates@2023-12-01' = {
  dependsOn: [
    appService
  ]
  name: 'wildcard'
  location: location
  properties: {
    hostNames: [
      '*.howdoyou.cloud'
      'howdoyou.cloud'
    ]
    keyVaultId: keyVault.id
    keyVaultSecretName: keyVaultSecretName
  }
}

output asuid string = appService.properties.customDomainVerificationId


