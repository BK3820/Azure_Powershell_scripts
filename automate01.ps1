[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$ResourcegroupName,

    [Parameter(Mandatory = $true)]
    [string]$Location,

    [Parameter(Mandatory = $true)]
    [string]$VmName,

    [Parameter(Mandatory = $true)]
    [string]$AdminUsername,

    [Parameter(Mandatory = $true)]
    [string]$AdminPassword
)

function Handle-Error {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error Message: $ErrorMessage" -ForegroundColor Red -BackgroundColor White
    
}


#RESOURCE GROUP CREATION

Write-Host "PROCESS --> Creating Resource group under the name '$ResourcegroupName' in the location '$Location'" -ForegroundColor DarkYellow
try {

    $Resourcegroup = Get-AzResourceGroup -Name $ResourcegroupName -ErrorAction SilentlyContinue 

    if ($Resourcegroup) {
        Write-Host "Resource group ALready exists under the name '$ResourcegroupName' , therefore skipping this creation"
    }
    else {
        New-AzResourceGroup -Name $ResourcegroupName -Location $Location -ErrorAction Inquire

        Write-Host "Resource group SUCCESSFULLY CREATED" -ForegroundColor Green
    }


    
}
catch {
    Handle-Error $_.Exception.Message
}



#VIRTUAL NETWORK CREATION

$vnetName = "$VmName-VNet"
$subnetName = "$vnetName-subnet"

Write-Host "PROCESS --> Creating Vnet under the name '$vnetName' in resource group '$ResourcegroupName'" -ForegroundColor DarkYellow

try {

    $vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourcegroupName -ErrorAction SilentlyContinue

    if ($vnet) {
        Write-Host "VNet ALready exists under the name '$vnetName' , therefore skipping this creation"
    }
    else {
        $vnet = New-AzVirtualNetwork -Name $vnetName -ResourceGroupName $ResourcegroupName -Location $Location -AddressPrefix "10.0.0.0/16" -Subnet @{ Name = $subnetName ; AddressPrefix = "10.0.0.0/24"} -ErrorAction Inquire

        Write-Host "VNet SUCCESSFULLY CREATED" -ForegroundColor Green

       
    }
    
}
catch {
    Handle-Error $_.Exception.Message
}



#NETWORK SECURITY GROUP CREATION

$nsgName = "$vmName-NSG"

Write-Host "PROCESS --> Creating NSG under the name '$nsgName' in resopurce group '$ResourcegroupName'" -ForegroundColor DarkYellow

try {
    $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourcegroupName -ErrorAction SilentlyContinue

    if ($nsg) {
        Write-Host "NSG ALready exists under the name '$nsgName' , therefore skipping this creation"
    }
    else{

        $securityrule = New-AzNetworkSecurityRuleConfig -Name "Allow_Http" -Protocol Tcp -SourcePortRange "*" -DestinationPortRange "3389" -SourceAddressPrefix "0.0.0.0/0" -DestinationAddressPrefix "*" -Access Allow -Priority 1000 -Direction "Inbound"

        New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $ResourcegroupName -Location $Location -SecurityRules $securityrule -ErrorAction Inquire

        Write-Host "NSG SUCCESSFULLY CREATED" -ForegroundColor Green
    }
}
catch {
    Handle-Error $_.Exception.Message
}


#NIC CREATION

$nicName = "$vmName-NIC"

Write-Host "PROCESS --> Creating NIC under the name '$nicName' in resopurce group '$ResourcegroupName'" -ForegroundColor DarkYellow

$subnetConfig = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName

$nic = Get-AzNetworkInterface -ResourceGroupName $ResourcegroupName -Name $nicName -ErrorAction SilentlyContinue

if($nic){
    Write-Host "NIC ALready exists under the name '$nicName' , therefore skipping this creation"
}
else {
   $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $ResourcegroupName -Location $Location -SubnetId $subnetConfig.Id -ErrorAction Inquire
    Write-Host "NIC SUCCESSFULLY CREATED" -ForegroundColor Green
}


#VM CONFIG

Write-Host "PROCESS --> Config VM under the name '$vmName' in resopurce group '$ResourcegroupName'" -ForegroundColor DarkYellow

$vmconfig = New-AzVMConfig -VMName $VmName -VMSize "Standard_B1ls" | Set-AzVMOperatingSystem -Windows -ComputerName $VmName -Credential(New-Object pscredential($AdminUsername, (ConvertTo-SecureString $AdminPassword -AsPlainText -Force))) | Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2019-Datacenter" -Version "Latest" | Add-AzVMNetworkInterface -Id $nic.Id

# Step 6: Create Virtual Machine
Write-Host "PROCESS --> Creating VM under the name '$vmName' in resopurce group '$ResourcegroupName'" -ForegroundColor DarkYellow

try {
   $vm = New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $vmconfig -ErrorAction Stop
   Write-Host "VM SUCCESSFULLY CREATED" -ForegroundColor Green
} catch {
   Handle-Error $_.Exception.Message
}
