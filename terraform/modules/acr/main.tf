resource "random_integer" "acr_suffix" {
  min = 10000
  max = 99999
}

locals {
  sanitized_acr_name = lower(replace(var.acr_name, "-", ""))
  unique_acr_name    = "${local.sanitized_acr_name}${random_integer.acr_suffix.result}"
}

resource "azurerm_container_registry" "acr" {
  name                = local.unique_acr_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  admin_enabled       = false
}
