output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Name of the deployed AKS cluster"
}

output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "Resource ID of the AKS cluster"
}

output "acr_login_server" {
  value       = azurerm_container_registry.acr.login_server
  description = "Login server for Azure Container Registry"
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "OIDC Issuer URL for Workload Identity"
}
