output "kube_config" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true

}
output "host" {
  value = azurerm_kubernetes_cluster.example.kube_config[0].host

}
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true

}
output "name" {
  value = azurerm_kubernetes_cluster.example.name

}
output "location" {
  value = azurerm_kubernetes_cluster.example.location

}
