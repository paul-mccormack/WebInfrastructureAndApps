using './main.bicep'

param tags = {
  'Created by': ''
  'Management Area': ''
  Service: ''
  Purpose: ''
  Recharge: ''
}
param firstRun = true
param uamiName = ''
param keyVaultName = ''
param certName = ''
param wafPolicyName = ''
param vnetName = ''
param vnetPrefix = ''
param agSubnetPrefix = ''
param backendSubnetPrefix = ''
param SqlSubnetPrefix = ''
param appGatewayName = ''
param appServicePlanName = ''
param defaultAppServiceUrl = ''

