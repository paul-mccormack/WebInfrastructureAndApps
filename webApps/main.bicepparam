using './main.bicep'

param tags = {
  'Created by': 'Paul McCormack'
  'Management Area': 'DDaT'
  Service: 'Websites'
  Purpose: 'Production'
  Recharge: 'DDaT'
}

param firstRun = false
param keyVaultName = 'kv-prod-websites-cert'
param keyVaultSecretName = 'wildcard'
param uamiName = 'uami-prod-websites-keyvault'
param vnetName = 'vnet-prod-websites'
param appServicePlanName = 'asp-uks-prod-websites01'
param appServicePrefix = 'default'
param customDomainName = 'testdeploy.howdoyou.cloud'
param sslThumbprint = 'CFEADA6E28F1FD26F58C4639A56B6188AC742CC5'
