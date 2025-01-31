# Define variables
$resourceGroupName = "MyResourceGroup"
$location = "EastUS"

# Convert GitHub Secret JSON string into a PowerShell object
$azureCredentials = ConvertFrom-Json -InputObject $env:AZURE_CREDENTIALS

# Login to Azure using Service Principal
Connect-AzAccount -ServicePrincipal `
    -TenantId $azureCredentials.tenantId `
    -ApplicationId $azureCredentials.clientId `
    -CertificateThumbprint $azureCredentials.clientSecret

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

Write-Output "Resource Group '$resourceGroupName' created successfully in '$location'."
