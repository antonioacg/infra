resource "vault_kubernetes_auth_backend_role" "terraform" {
  backend                          = "kubernetes" # This assumes the Kubernetes auth backend is mounted at 'kubernetes'
  role_name                        = var.role_name
  bound_service_account_names      = var.bound_service_account_names
  bound_service_account_namespaces = var.bound_service_account_namespaces
  token_ttl                        = var.token_ttl
  token_policies                   = [var.policy_name] # Referencing the policy created in policies.tf
}
