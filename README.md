Bicep templates to deploy an Azure App Gateway along with supporting infrastructure and KeyVault for certificate upload and retrieval.  Includes code to deploy an App Service webapp as the backend to prove the Application Gateway is operational.  Future work is to add databases for the webapps and the ability to host container apps behind the Application Gateway.

Steps to deploy this example are:

1. Run Infrastructure main with firstRun parameter set to 'true' to deploy KeyVault, WAF Policy, vnet, App Service Plan and managed identity.
2. Upload certificate (pfx) to keyvault and record name.  Temporarily create yourself an access policy on the KeyVault then remove it once done.
3. Create DNS record for domain name pointing to public IP created in step 1.
4. Run webApps main with firstRun parameter set to 'true' to deploy App Service and record Custom Domain Verification ID and default url for App Service.
5. create a TXT record with the DNS provider host: asuid  value: custom domain Verification ID.
6. Run webApps main with firstRun parameter set to 'false' to do custom domain name binding and certificate binding.
7. Run Infrastructure main with firstRun parameter set to 'false' and App Service default URL in defaultAppServiceUrl paramter to deploy App Gateway and link everything together.

The App Service is configured to only accept incoming traffic from the App Gateway vnet.  To check everything is working you can navigate in the portal to the App Service, click the default domain and you should be denied access.  Click the custom URL and you should see the App Service dotnet landing page.

