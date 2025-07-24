# Example: Complete Azure infrastructure with CAF naming

terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = "~> 1.2.28"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azurecaf" {}

# Generate CAF-compliant names
data "azurecaf_name" "resource_group" {
  name          = "myproject"
  resource_type = "azurerm_resource_group"
  prefixes      = ["caf"]
  suffixes      = ["001"]
  clean_input   = true
}

data "azurecaf_name" "storage_account" {
  name          = "myproject"
  resource_type = "azurerm_storage_account"
  prefixes      = ["caf"]
  suffixes      = ["001"]
  clean_input   = true
}

data "azurecaf_name" "app_service" {
  name          = "myproject"
  resource_type = "azurerm_app_service"
  prefixes      = ["caf"]
  suffixes      = ["001"]
  clean_input   = true
}

# Create resources with CAF-compliant names
resource "azurerm_resource_group" "example" {
  name     = data.azurecaf_name.resource_group.result
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = data.azurecaf_name.storage_account.result
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "${data.azurecaf_name.app_service.result}-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = data.azurecaf_name.app_service.result
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id
}

# Output the generated names
output "resource_group_name" {
  value = data.azurecaf_name.resource_group.result
}

output "storage_account_name" {
  value = data.azurecaf_name.storage_account.result
}

output "app_service_name" {
  value = data.azurecaf_name.app_service.result
}
