# Ensure Az module is installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Install-Module -Name Az -Scope CurrentUser -Force -AllowClobber
}

# Retrieve environment variables set by GitHub Secrets
$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET
$subscriptionId = $env:AZURE_SUBSCRIPTION_ID
$tenantId = $env:AZURE_TENANT_ID

# Convert client secret to a secure string
$securePassword = ConvertTo-SecureString $clientSecret -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($clientId, $securePassword)

# Authenticate with Azure using Service Principal
Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantId -SubscriptionId $subscriptionId

# Define Resource Group name and location
$resourceGroupName = "TestResourceGroup"
$location = "East US"

# Create Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Output confirmation message
Write-Output "Resource Group '$resourceGroupName' created successfully in '$location'."
