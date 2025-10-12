# Vault Module Outputs

output "endpoint" {
  description = "Vault endpoint URL"
  value       = "http://vault.vault.svc.cluster.local:8200"
}

output "external_endpoint" {
  description = "Vault endpoint accessible via port-forward"
  value       = "http://localhost:8200"
}

output "namespace" {
  description = "Vault namespace"
  value       = kubernetes_namespace.vault.metadata[0].name
}

output "service_name" {
  description = "Vault service name"
  value       = "vault"
}

output "storage_backend" {
  description = "Configured storage backend"
  value       = var.storage_backend
}

output "ha_enabled" {
  description = "Whether HA mode is enabled"
  value       = var.vault_ha_enabled
}

output "replicas" {
  description = "Number of Vault replicas"
  value       = var.vault_replicas
}