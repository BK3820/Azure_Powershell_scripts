# Ensure Az module is installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber
}

# Authenticate using Service Principal (credentials set via environment variables)
$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET
$subscriptionId = $env:AZURE_SUBSCRIPTION_ID
$tenantId = $env:AZURE_TENANT_ID

$securePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($clientId, $securePassword)

# Login to Azure
Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantId -SubscriptionId $subscriptionId

# Define Resource Group name and location
$resourceGroupName = "TestResourceGroup"
$location = "East US"

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Output confirmation message
Write-Output "Resource Group '$resourceGroupName' created successfully in '$location'."
