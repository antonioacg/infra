# Vault authentication for External Secrets Operator
# This enables External Secrets to read secrets from Vault

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s" {
  backend         = vault_auth_backend.kubernetes.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
}

# Policy for External Secrets to read all secrets
resource "vault_policy" "external_secrets" {
  name = "external-secrets"

  policy = <<EOT
path "secret/data/*" {
  capabilities = ["read"]
}

path "secret/metadata/*" {
  capabilities = ["list", "read"]
}
EOT
}

# Role for External Secrets service account
resource "vault_kubernetes_auth_backend_role" "external_secrets" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "external-secrets"
  bound_service_account_names      = ["external-secrets-operator"]
  bound_service_account_namespaces = ["external-secrets-system"]
  token_policies                   = [vault_policy.external_secrets.name]
  token_ttl                        = 3600
  token_max_ttl                    = 7200
}