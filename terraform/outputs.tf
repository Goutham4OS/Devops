output "resource_group_name" {
  value = module.rg.name
}

output "vnet_subnet_id" {
  value = module.vnet.subnet_id
}

output "acr_id" {
  value = module.acr.acr_id
}

output "acr_name" {
  value = module.acr.acr_name
}

output "aks_fqdn" {
  value = module.aks.aks_fqdn
}

output "log_analytics_workspace_id" {
  value = module.log_analytics.workspace_id
}

output "traffic_manager_fqdn" {
  value = module.traffic_manager.fqdn
}
