terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Configure the Microsoft Azure Provider
# Subscription ID must be set via ARM_SUBSCRIPTION_ID environment variable
# or explicitly in the provider block (not recommended for security)
# 
# To set environment variable:
#   PowerShell: $env:ARM_SUBSCRIPTION_ID = "your-subscription-id"
#   Bash: export ARM_SUBSCRIPTION_ID="your-subscription-id"
#   Or use: .\setup-env.ps1 (from project root)
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

module "resource_group" {
  source   = "../../Modules/resource-group"
  name     = var.resource_group_name
  location = var.location
}

module "ACR" {
  source              = "../../Modules/ACR"
  name                = var.acr_name
  location            = var.location
  resource_group_name = module.resource_group.name
}

module "keyvaults" {
  source              = "../../Modules/keyvaults"
  name                = "nimbus-eus-dev01"
  location            = var.location
  resource_group_name = module.resource_group.name
}

module "AKS" {
  source              = "../../Modules/AKS"
  name                = var.aks_name
  location            = var.location
  resource_group_name = module.resource_group.name
  node_count          = var.node_count
  vm_size             = var.vm_size
  environment         = var.environment
  owner               = var.owner
  acr_id              = module.ACR.acr_id
}
