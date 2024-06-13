param location string
param appServicePlanName string
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'windows'
  sku: {
    name: 'B1'
  }
}

output appServicePlanId string = appServicePlan.id
