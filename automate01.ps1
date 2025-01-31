# Ensure authentication in Azure using GitHub Secrets
Write-Host "Authenticating to Azure..."
$clientId = "${{ secrets.AZURE_CLIENT_ID }}"
$clientSecret = "${{ secrets.AZURE_CLIENT_SECRET }}"
$tenantId = "${{ secrets.AZURE_TENANT_ID }}"
$subscriptionId = "${{ secrets.AZURE_SUBSCRIPTION_ID }}"

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
