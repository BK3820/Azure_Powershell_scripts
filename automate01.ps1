# Define variables
$resourceGroupName = "MyResourceGroup"
$location = "EastUS"


# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Confirm creation
Write-Output "Resource Group '$resourceGroupName' created successfully in '$location'."
