using './main.bicep'

param tags = {
  'Created by': 'Paul McCormack'
  'Management Area': 'DDaT'
  Service: 'Websites'
  Purpose: 'Production'
  Recharge: 'DDaT'
}
param firstRun = false
param uamiName = 'uami-prod-websites-keyvault'
param keyVaultName = 'kv-prod-websites-cert'
param certName = 'wildcard'
param wafPolicyName = 'wafpol-prod-websites'
param vnetName = 'vnet-prod-websites'
param vnetPrefix = '10.0.0.0/16'
param agSubnetPrefix = '10.0.0.0/24'
param backendSubnetPrefix = '10.0.1.0/24'
param appGatewayName = 'ag-uks-prod-websites01'
param appServicePlanName = 'asp-uks-prod-websites01'
param defaultAppServiceUrl = 'defaultrbshotyfkaw7a.azurewebsites.net'

