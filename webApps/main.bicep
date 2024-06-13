@description('Location of resources from location of Resource Group')
param location string = resourceGroup().location

@description('Tags.  Always with the tags.')
param tags object

param uamiName string
param vnetName string
param keyVaultName string
param keyVaultSecretName string
param appServicePlanName string
param appServicePrefix string
param customDomainName string
param sslThumbprint string
param firstRun bool

var appServiceName = toLower('${appServicePrefix}${uniqueString(resourceGroup().id)}')

module appService 'modules/appService.bicep' = {
  name: appServiceName
  params: {
    appServiceName: appServiceName
    location: location
    tags: tags
    uamiName: uamiName
    vnetName: vnetName
    keyVaultName: keyVaultName
    keyVaultSecretName: keyVaultSecretName
    appServicePlanName: appServicePlanName
  }
}

module customDomainAndSSL 'modules/customDomainAndSSL.bicep' = if (firstRun == false) {
  name: 'applySslAndUrl'
  params: {
    appServiceName: appServiceName
    customDomainName: customDomainName
    sslThumbprint: sslThumbprint
  }
}

output customDomainVerificationId object = appService.outputs
