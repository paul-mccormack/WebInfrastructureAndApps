param location string
param tags object
param wafPolicyName string

@description('Firewal mode')
@allowed([ 'Detection', 'Prevention' ])
param firewallMode string = 'Detection'

resource wafPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2023-09-01' = {
  name: wafPolicyName
  location: location
  tags: tags
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: firewallMode
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.2'
          ruleGroupOverrides: [
            {
              ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
              rules: [
                {
                  ruleId: '920300'
                  state: 'Enabled'
                  action: 'Log'
                }
              ]
            }
          ]
        }
      ]
      exclusions: [
        {
          exclusionManagedRuleSets: [
            {
              ruleSetType: 'OWASP'
              ruleSetVersion: '3.2'
              ruleGroups: [
                {
                  ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
                  rules: [
                    {
                      ruleId: '942450'
                    }
                  ]
                }
              ]
            }
          ]
          matchVariable: 'RequestCookieNames'
          selector: 'myapp_session'
          selectorMatchOperator: 'Equals'
        }
      ]
    }
  }
}

output id string = wafPolicy.id
