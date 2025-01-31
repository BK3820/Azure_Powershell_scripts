# Ensure authentication in Azure using environment variables
Write-Host "Authenticating to Azure..."
$clientId = $env:AZURE_CLIENT_ID
$clientSecret = $env:AZURE_CLIENT_SECRET
$tenantId = $env:AZURE_TENANT_ID
$subscriptionId = $env:AZURE_SUBSCRIPTION_ID

Connect-AzAccount -ServicePrincipal -TenantId $tenantId -ApplicationId $clientId -CertificateThumbprint $clientSecret
Set-AzContext -SubscriptionId $subscriptionId

Write-Host "Azure authentication successful."

# Define variables
$ResourcegroupName = "MyResourceGroup"
$Location = "EastUS"
$VmName = "MyVM"
$AdminUsername = "adminuser"
$AdminPassword = "MySecureP@ss!"

# RESOURCE GROUP CREATION
Write-Host "PROCESS --> Creating Resource group under the name '$ResourcegroupName' in the location '$Location'" -ForegroundColor DarkYellow
try {
    $Resourcegroup = Get-AzResourceGroup -Name $ResourcegroupName -ErrorAction SilentlyContinue
    if ($Resourcegroup) {
        Write-Host "Resource group already exists, skipping creation."
    } else {
        New-AzResourceGroup -Name $ResourcegroupName -Location $Location -ErrorAction Stop
        Write-Host "Resource group successfully created." -ForegroundColor Green
    }
} catch {
    Write-Host "Error Message: $_.Exception.Message" -ForegroundColor Red -BackgroundColor White
}
