terraform {
  required_providers {
    azurecaf = {
      source  = "aztfmodnew/azurecaf"
      version = ">= 1.2.0"
    }
  }
}

provider "azurecaf" {
}
