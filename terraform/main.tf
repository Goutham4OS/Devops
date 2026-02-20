terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

module "rg" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = module.rg.name
  location            = module.rg.location
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  resource_group_name = module.rg.name
  location            = module.rg.location
  workspace_name      = var.log_workspace_name
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = module.rg.name
  location            = module.rg.location
  acr_name            = var.acr_name
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = module.rg.name
  location            = module.rg.location
  cluster_name        = var.aks_name
  subnet_id           = module.vnet.subnet_id
  log_workspace_id    = module.log_analytics.workspace_id
  acr_id              = module.acr.acr_id
}

module "traffic_manager" {
  source              = "./modules/traffic_manager"
  resource_group_name = module.rg.name
  tm_name             = var.tm_name
  target_dns          = module.aks.aks_fqdn
}
