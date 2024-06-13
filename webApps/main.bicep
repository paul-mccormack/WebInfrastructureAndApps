@description('Location of resources from location of Resource Group')
param location string = resourceGroup().location

@description('Tags.  Always with the tags.')
param tags object

@description('If this is first run set to true')
param firstRun bool

@description('User Managed Identity Name')
param uamiName string

@description('vnet Name')
param vnetName string

@description('KeyVault Name')
param keyVaultName string

@description('Cert Name in KeyVault')
param keyVaultSecretName string

@description('App Service Plan Name')
param appServicePlanName string

@description('Prefix name for App Service')
param appServicePrefix string

@description('Custom Domain Name for App Service')
param customDomainName string

@description('SSL Thumbprint of uploaded certificate')
param sslThumbprint string

@description('Build App Service Name')
var appServiceName = toLower('${appServicePrefix}${uniqueString(resourceGroup().id)}')

@description('Module to Deploy App Service')
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

@description('Module to Apply custom domain name and SSL')
module customDomainAndSSL 'modules/customDomainAndSSL.bicep' = if (firstRun == false) {
  name: 'applySslAndUrl'
  params: {
    appServiceName: appServiceName
    customDomainName: customDomainName
    sslThumbprint: sslThumbprint
  }
}

output customDomainVerificationId object = appService.outputs
