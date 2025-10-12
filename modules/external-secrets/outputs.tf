# External Secrets Module Outputs

output "namespace" {
  description = "External Secrets namespace"
  value       = kubernetes_namespace.external_secrets.metadata[0].name
}

output "service_account_name" {
  description = "External Secrets service account name"
  value       = kubernetes_service_account.vault_auth.metadata[0].name
}

output "cluster_secret_store_name" {
  description = "ClusterSecretStore name for Vault"
  value       = "vault-backend"
}