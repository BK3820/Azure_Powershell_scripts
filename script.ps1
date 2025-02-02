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


Param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [Int32]$Vmcount,

    [Parameter(Mandatory = $true)]
    [string]$adminUser,

    [Parameter(Mandatory = $true)]
    [string]$adminPassword  # Accepting as plain string
)

# Convert password inside script
$securePassword = ConvertTo-SecureString $adminPassword -AsPlainText -Force

Write-Host "Initiating Resource Group Creation"

try {
    $RG = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue

    if ($RG) {
        Write-Warning "Resource Group '$ResourceGroup' already exists."
    }
    else {
        New-AzResourceGroup -Name $ResourceGroup -Location $Location
        Write-Host "Resource Group '$ResourceGroup' Created." -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

Write-Host "Creating $Vmcount VMs"

try {
    for ($i = 1; $i -le $Vmcount; $i++) {
        $vmName = "vm0-$i"
        $cred = New-Object System.Management.Automation.PSCredential ($adminUser, $securePassword)

        New-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -Location $Location -Credential $cred -Image "Ubuntu2204"
        Write-Host "VM $vmName created successfully." -ForegroundColor Green
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}

