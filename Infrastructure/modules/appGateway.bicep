param location string  = resourceGroup().location
param tags object
param appGatewayName string
param wafPolicyName string
param userAssignedIdentity string
param vnetName string
param appServiceURL string
param keyVaultName string
param certName string

var publicIpName = 'pip-${appGatewayName}'

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-09-01' existing = {
  name: wafPolicyName
}

resource publicIp 'Microsoft.Network/publicIPAddresses@2023-11-01'  existing = {
  name: publicIpName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: userAssignedIdentity
}

resource appGateway 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: appGatewayName
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      family: 'Generation_2'
    }
    forceFirewallPolicyAssociation: true
    firewallPolicy: {
      id: wafPolicy.id
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, 'AGSubnet')
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGatewayFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'Port80'
        properties: {
          port: 80
        }
      }
      {
        name: 'Port443'
        properties: {
          port: 443
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaultHttpsBackendSettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'defaultBackEndPool'
        properties: {
          backendAddresses: [
            {
              fqdn: appServiceURL
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'defaultHttpListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGatewayFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'Port80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
      {
        name: 'defaultHttpsListener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', appGatewayName, 'appGatewayFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', appGatewayName, 'Port443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', appGatewayName, 'wildCard')
          }
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'defaultRoutingRule'
        properties: {
          ruleType: 'Basic'
          priority: 1
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'defaultHttpsListener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', appGatewayName,'defaultBackEndPool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGatewayName,'defaultHttpsBackendSettings')
          }
          rewriteRuleSet: {
            id: resourceId('Microsoft.Network/applicationGateways/rewriteRuleSets', appGatewayName, 'Response-Header-Rewrites')
          }
        }
      }
      {
        name: 'defaultHttpToHttpsRedirect'
        properties: {
          ruleType: 'Basic'
          priority: 2
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'defaultHttpListener')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', appGatewayName, 'defaultHttpToHttpsRedirect')
          }
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'defaultHttpToHttpsRedirect'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', appGatewayName, 'defaultHttpsListener')
          }
          includePath: true
          includeQueryString: true
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'Response-Header-Rewrites'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              name: 'Strict-Transport-Security'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'Strict-Transport-Security'
                    headerValue: 'max-age=31536000; includeSubDomains'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'X-Frame-Options'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'X-Frame-Options'
                    headerValue: 'SAMEORIGIN'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'X-XSS-Protection'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'X-XSS-Protection'
                    headerValue: '1; mode=block'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'X-Content-Type-Options'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'X-Content-Type-Options'
                    headerValue: 'nosniff'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'Referrer-Policy'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'Referrer-Policy'
                    headerValue: 'SAME-ORIGIN'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'Content-Security-Policy'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'Content-Security-Policy'
                    headerValue: 'frame-ancestors \'self\';'
                  }
                ]
              }
            }
            {
              ruleSequence: 100
              name: 'Permissions-Policy'
              actionSet: {
                responseHeaderConfigurations: [
                  {
                    headerName: 'Permissions-Policy'
                    headerValue: 'geolocation=(),midi=(),microphone=(),camera=(),magnetometer=(),gyroscope=(),fullscreen=(self)'
                  }
                ]
              }
            }
          ]
        }
      }
    ]
sslCertificates: [
      {
        name: 'wildCard'
        properties: {
          keyVaultSecretId: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/secrets/${certName}'
        }
      }
    ]
  }
}

