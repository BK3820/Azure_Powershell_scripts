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
    [securestring]$adminPassword
)

function HandleError {
    param (
        [string]$ErrorMessage
    )

    Write-Host "Error Message: $ErrorMessage" -ForegroundColor Red
}

Write-Host "Initiating Resource Group Creation"
try {
    # Check if Resource Group exists
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
    HandleError $_.Exception.Message
    exit 1  # Stop execution if RG creation fails
}

Write-Host "Initiating VM Creation: Expecting $Vmcount VMs"

try {
    $i = 1  # Initialize counter
    while ($i -le $Vmcount) {
        $vmName = "vm0-$i"

        # Ensure credentials are passed correctly
        $cred = New-Object System.Management.Automation.PSCredential ($adminUser, $adminPassword)

        # Create VM
        New-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -Location $Location -Credential $cred -Image "Ubuntu2204"

        # Wait and Check VM Status
        try {
            Start-Sleep -Seconds 60

            $vmStatus = (Get-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -Status).Statuses[1].Code

            if ($vmStatus -eq "PowerState/running") {
                Write-Host "$vmName is created and running..." -ForegroundColor Green
            }
            else {
                Write-Host "$vmName is created but not starting... waiting another 25 seconds"
                Start-Sleep -Seconds 25

                $vmStatus = (Get-AzVM -ResourceGroupName $ResourceGroup -Name $vmName -Status).Statuses[1].Code

                if ($vmStatus -eq "PowerState/running") {
                    Write-Host "$vmName is now running..." -ForegroundColor Green
                }
                else {
                    Write-Host "$vmName did not start, exiting..." -ForegroundColor Red
                    exit
                }
            }
        }
        catch {
            HandleError $_.Exception.Message
        }

        $i++
    }
}
catch {
    HandleError $_.Exception.Message
}

