# =============================================================================
# OPENTOFU/TERRAFORM - Azure Container Apps Deployment
# =============================================================================
# Deploys: API + UI + Container Registry
# =============================================================================

terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# -----------------------------------------------------------------------------
# Provider Configuration
# -----------------------------------------------------------------------------
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.app_name}-${var.environment}"
  location = var.location
  
  tags = {
    environment = var.environment
    app         = var.app_name
  }
}

# -----------------------------------------------------------------------------
# Container Registry (to store Docker images)
# -----------------------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  name                = replace("acr${var.app_name}${var.environment}", "-", "")
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false  # Using Managed Identity instead
  
  tags = {
    environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# User Assigned Managed Identity (for ACR pull)
# -----------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = "id-${var.app_name}-acr-pull"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  
  tags = {
    environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Role Assignment - Give MI permission to pull from ACR
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
}

# -----------------------------------------------------------------------------
# Log Analytics (for Container Apps logs)
# -----------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.app_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -----------------------------------------------------------------------------
# Container Apps Environment
# -----------------------------------------------------------------------------
resource "azurerm_container_app_environment" "main" {
  name                       = "cae-${var.app_name}-${var.environment}"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  tags = {
    environment = var.environment
  }
}

# -----------------------------------------------------------------------------
# Container App - API (Backend)
# -----------------------------------------------------------------------------
resource "azurerm_container_app" "api" {
  name                         = "ca-${var.app_name}-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  
  # Use Managed Identity for ACR authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull.id]
  }
  
  # Registry with Managed Identity (no password needed!)
  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.acr_pull.id
  }
  
  template {
    container {
      name   = "api"
      image  = "${azurerm_container_registry.main.login_server}/${var.app_name}-api:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
      
      env {
        name  = "ENV"
        value = var.environment
      }
    }
    
    # Scale settings
    min_replicas = 0  # Scale to zero when idle
    max_replicas = 3
  }
  
  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "http"
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  
  tags = {
    environment = var.environment
    component   = "api"
  }
  
  depends_on = [azurerm_role_assignment.acr_pull]
}

# -----------------------------------------------------------------------------
# Container App - UI (Frontend)
# -----------------------------------------------------------------------------
resource "azurerm_container_app" "ui" {
  name                         = "ca-${var.app_name}-ui"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  
  # Use Managed Identity for ACR authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull.id]
  }
  
  # Registry with Managed Identity (no password needed!)
  registry {
    server   = azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.acr_pull.id
  }
  
  template {
    container {
      name   = "ui"
      image  = "${azurerm_container_registry.main.login_server}/${var.app_name}-ui:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
      
      # UI connects to API using its FQDN (public URL)
      env {
        name  = "API_URL"
        value = "https://${azurerm_container_app.api.ingress[0].fqdn}"
      }
    }
    
    min_replicas = 0
    max_replicas = 3
  }
  
  ingress {
    external_enabled = true
    target_port      = 8501
    transport        = "http"
    
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  
  tags = {
    environment = var.environment
    component   = "ui"
  }
  
  # UI depends on API being created first (to get the URL)
  depends_on = [azurerm_container_app.api, azurerm_role_assignment.acr_pull]
}
