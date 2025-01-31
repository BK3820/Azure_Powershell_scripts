# Ensure authentication in Azure
Write-Host "Authenticating to Azure..."
Connect-AzAccount -Identity
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
