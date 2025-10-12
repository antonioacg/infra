# Production Environment Outputs

output "vault_endpoint" {
  description = "Vault endpoint URL"
  value       = module.vault.endpoint
}

output "vault_namespace" {
  description = "Vault namespace"
  value       = module.vault.namespace
}

output "external_secrets_namespace" {
  description = "External Secrets namespace"
  value       = module.external_secrets.namespace
}

output "ingress_controller_namespace" {
  description = "Nginx Ingress Controller namespace"
  value       = module.networking.ingress_namespace
}

output "environment_phase" {
  description = "Current environment phase"
  value       = var.environment
}

output "node_count" {
  description = "Configured node count"
  value       = var.node_count
}