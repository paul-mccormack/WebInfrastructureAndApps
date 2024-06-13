@description('Location of resources from location of Resource Group')
param location string = resourceGroup().location

@description('Tags.  Always with the tags.')
param tags object

@description('If this is first run set to true')
param firstRun bool

@description('Name of Uer Assigned Managed Identity for retrieving certs from KeyVault')
param uamiName string

@description('Name of KeyVault and Certificate')
param keyVaultName string
param certName string

@description('Web Application Firewall Policy Name')
param wafPolicyName string

@description('Vnet details')
param vnetName string
param vnetPrefix string
param agSubnetPrefix string
param backendSubnetPrefix string

@description('App Gateway Name')
param appGatewayName string

@description('App Service Plan name')
param appServicePlanName string

@description('Default App Service to test App Gateway Deployment')
param defaultAppServiceUrl string

@description('Create Public IP for App Gateway')
var publicIpName = 'pip-${appGatewayName}'

@description('Module to deploy User Assigned Managed Identity')
module userAssignedManagedIdentity 'modules/appGatewayIdentity.bicep' = {
  name: uamiName
  params: {
    uamiName: uamiName
    location: location
    tags: tags
  }
}

@description('Module to deploy KeyVault')
module keyVault 'modules/keyVault.bicep' = {
  name: keyVaultName
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
    appGatewayIdentity: userAssignedManagedIdentity.outputs.principalId
  }
  dependsOn: [
    userAssignedManagedIdentity
  ]
}

@description('Module to deploy WAF Policy')
module wafPolicy 'modules/appGatewayWafPolicy.bicep' = {
  name: wafPolicyName
  params: {
    wafPolicyName: wafPolicyName
    location: location
    tags: tags
  }
}

module publicIP 'modules/publicIP.bicep' = {
  name: publicIpName
  params: {
    appGatewayName: appGatewayName
    location: location
    tags: tags
  }
}

@description('Module to deploy vnet')
module vnet 'modules/vnet.bicep' = {
  name: vnetName
  params: {
    vnetName: vnetName
    location: location
    tags: tags
    vnetPrefix: vnetPrefix
    agSubnetPrefix: agSubnetPrefix
    backendSubnetPrefix: backendSubnetPrefix
  }
}

@description('Module to deploy App Service Plan')
module appServicePlan 'modules/appServicePlan.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: appServicePlanName
  params: {
    appServicePlanName: appServicePlanName
    location: location
    tags: tags
  }
}

@description('Module to deploy App Gateway.  This should only be run after certifcate has been uploaded to the keyvault.  Set firstRun parameter to false')
module appGateway 'modules/appGateway.bicep' = if (firstRun == false) {
  name: appGatewayName
  params: {
    appGatewayName: appGatewayName
    location: location
    tags: tags
    vnetName: vnetName
    wafPolicyName: wafPolicyName
    keyVaultName: keyVaultName
    certName: certName
    appServiceURL: defaultAppServiceUrl
    userAssignedIdentity: userAssignedManagedIdentity.outputs.resourceId
  }
}

output publicIPAddress object = publicIP.outputs
