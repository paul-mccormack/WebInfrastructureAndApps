using './main.bicep'

param tags = {
  'Created by': ''
  'Management Area': ''
  Service: ''
  Purpose: ''
  Recharge: ''
}

param firstRun = true
param keyVaultName = ''
param keyVaultSecretName = ''
param uamiName = ''
param vnetName = ''
param appServicePlanName = ''
param appServicePrefix = ''
param customDomainName = ''
param sslThumbprint = ''
