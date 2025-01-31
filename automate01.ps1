[CmdletBinding()]

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

# VIRTUAL NETWORK CREATION
$vnetName = "$VmName-VNet"
$subnetName = "$vnetName-subnet"

Write-Host "PROCESS --> Creating VNet under the name '$vnetName' in resource group '$ResourcegroupName'" -ForegroundColor DarkYellow
try {
    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourcegroupName -ErrorAction SilentlyContinue
    if ($vnet) {
        Write-Host "VNet already exists, skipping creation."
    } else {
        $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourcegroupName -Location $Location -AddressPrefix "10.0.0.0/16" -Subnet @{
            Name = $subnetName
            AddressPrefix = "10.0.0.0/24"
        } -ErrorAction Stop
        Write-Host "VNet successfully created." -ForegroundColor Green
    }
} catch {
    Handle-Error $_.Exception.Message
}

# NETWORK SECURITY GROUP CREATION
$nsgName = "$VmName-NSG"
Write-Host "PROCESS --> Creating NSG under the name '$nsgName' in resource group '$ResourcegroupName'" -ForegroundColor DarkYellow
try {
    $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourcegroupName -ErrorAction SilentlyContinue
    if ($nsg) {
        Write-Host "NSG already exists, skipping creation."
    } else {
        $securityrule = New-AzNetworkSecurityRuleConfig -Name "Allow_RDP" -Protocol Tcp -SourcePortRange "*" -DestinationPortRange "3389" -SourceAddressPrefix "0.0.0.0/0" -DestinationAddressPrefix "*" -Access Allow -Priority 1000 -Direction "Inbound"
        New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourcegroupName -Location $Location -SecurityRules $securityrule -ErrorAction Stop
        Write-Host "NSG successfully created." -ForegroundColor Green
    }
} catch {
    Handle-Error $_.Exception.Message
}

# NIC CREATION
$nicName = "$VmName-NIC"
Write-Host "PROCESS --> Creating NIC under the name '$nicName' in resource group '$ResourcegroupName'" -ForegroundColor DarkYellow
try {
    $subnetConfig = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName
    $nic = Get-AzNetworkInterface -ResourceGroupName $ResourcegroupName -Name $nicName -ErrorAction SilentlyContinue
    if ($nic) {
        Write-Host "NIC already exists, skipping creation."
    } else {
        $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $ResourcegroupName -Location $Location -SubnetId $subnetConfig.Id -ErrorAction Stop
        Write-Host "NIC successfully created." -ForegroundColor Green
    }
} catch {
    Handle-Error $_.Exception.Message
}

# VM CONFIGURATION AND CREATION
Write-Host "PROCESS --> Configuring and creating VM under the name '$VmName' in resource group '$ResourcegroupName'" -ForegroundColor DarkYellow
try {
    $cred = New-Object System.Management.Automation.PSCredential ($AdminUsername, (ConvertTo-SecureString $AdminPassword -AsPlainText -Force))
    $vmconfig = New-AzVMConfig -VMName $VmName -VMSize "Standard_B1ls" | 
                Set-AzVMOperatingSystem -Windows -ComputerName $VmName -Credential $cred | 
                Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "Latest" | 
                Add-AzVMNetworkInterface -Id $nic.Id

    # Create the VM
    $vm = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmconfig -ErrorAction Stop
    Write-Host "VM successfully created." -ForegroundColor Green
} catch {
    Handle-Error $_.Exception.Message
}
