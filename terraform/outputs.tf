# =============================================================================
# OUTPUTS - URLs and information after deployment
# =============================================================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "managed_identity_id" {
  description = "Managed Identity used for ACR pull"
  value       = azurerm_user_assigned_identity.acr_pull.id
}

output "managed_identity_client_id" {
  description = "Managed Identity client ID"
  value       = azurerm_user_assigned_identity.acr_pull.client_id
}

output "api_url" {
  description = "URL of the API (FastAPI)"
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}

output "api_docs_url" {
  description = "URL of the API documentation"
  value       = "https://${azurerm_container_app.api.ingress[0].fqdn}/docs"
}

output "ui_url" {
  description = "URL of the UI (Streamlit)"
  value       = "https://${azurerm_container_app.ui.ingress[0].fqdn}"
}

# Quick command to login to ACR (uses your Azure CLI identity)
output "acr_login_command" {
  description = "Command to login to ACR"
  value       = "az acr login --name ${azurerm_container_registry.main.name}"
}
