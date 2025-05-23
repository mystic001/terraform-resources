# Parameters
$resourceGroupName = "rg-terraform-state"
$location = "eastus"
$storageAccountName = "tfstate" + (Get-Random -Minimum 1000 -Maximum 9999)
$containerName = "tfstate"

# Login to Azure (if not already logged in)
Write-Host "Logging in to Azure..."
az login

# Create Resource Group
Write-Host "Creating Resource Group: $resourceGroupName"
az group create --name $resourceGroupName --location $location

# Create Storage Account
Write-Host "Creating Storage Account: $storageAccountName"
az storage account create `
    --name $storageAccountName `
    --resource-group $resourceGroupName `
    --location $location `
    --sku Standard_LRS `
    --encryption-services blob

# Get Storage Account Key
Write-Host "Getting Storage Account Key..."
$storageAccountKey = (az storage account keys list `
    --resource-group $resourceGroupName `
    --account-name $storageAccountName `
    --query '[0].value' `
    --output tsv)

# Create Container
Write-Host "Creating Container: $containerName"
az storage container create `
    --name $containerName `
    --account-name $storageAccountName `
    --account-key $storageAccountKey

# Output the backend configuration
Write-Host "`nTerraform Backend Configuration:"
Write-Host "--------------------------------"
Write-Host "Add the following to your backend.tf file:"
Write-Host @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$resourceGroupName"
    storage_account_name = "$storageAccountName"
    container_name       = "$containerName"
    key                  = "terraform.tfstate"
  }
}
"@

Write-Host "`nBackend setup completed successfully!" 