# Removed [CmdletBinding()]
function Handle-Error {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error Message: $ErrorMessage" -ForegroundColor Red -BackgroundColor White
}

# Define variables (Previously passed as parameters)
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
    Handle-Error $_.Exception.Message
}
