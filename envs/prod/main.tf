module "vault_secrets" {
  source  = "../../modules/vault"
  secrets = var.vault_secrets
}

module "vault_auth_kubernetes" {
  source = "../../modules/vault-auth"
  # The module uses default values for role_name, policy_name, service account, and namespace
  # which align with the setup: 
  # role_name                        = "terraform"
  # bound_service_account_names      = ["terraform"]
  # bound_service_account_namespaces = ["vault"]
  # policy_name                      = "terraform"
}