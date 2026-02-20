resource "azurerm_traffic_manager_profile" "tm" {
  name                   = var.tm_name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = var.tm_name
    ttl           = 60
  }

  monitor_config {
    protocol = "HTTPS"
    port     = 443
    path     = "/"
  }
}

resource "azurerm_traffic_manager_endpoint" "endpoint" {
  name       = "aks-endpoint"
  profile_id = azurerm_traffic_manager_profile.tm.id
  type       = "externalEndpoints"
  target     = var.target_dns
  priority   = 1
}
