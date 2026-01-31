# Uncomment when deploying apps that need user-provided secrets (cloudflared, datadog, etc.)
# Pass VAULT_INPUT_<key>=<value> during bootstrap to populate secret/bootstrap/inputs
# data "vault_kv_secret_v2" "bootstrap_inputs" {
#   mount = "secret"
#   name  = "bootstrap/inputs"
# }

# Read tf-controller's MinIO credentials (stored by bootstrap phase 2)
data "vault_kv_secret_v2" "tf_minio" {
  mount = "secret"
  name  = "infra/minio/tf-user"
}

# tf-controller's MinIO credentials (synced to flux-system for runner pod)
# Bootstrap creates tf-user with access only to terraform-state bucket
module "tf_minio_credentials" {
  source      = "../vault-secret"
  name        = "infra/minio/tf-user"
  namespace   = "flux-system"
  secret_name = "tf-minio-credentials"

  # Read from Vault (bootstrap stored these) and ensure Vault secret exists
  values = {
    access_key = data.vault_kv_secret_v2.tf_minio.data["access_key"]
    secret_key = data.vault_kv_secret_v2.tf_minio.data["secret_key"]
  }
}

# Example usage for app secrets:
# module "redis" {
#   source    = "../vault-secret"
#   name      = "apps/redis"
#   namespace = "redis"
#   keys      = ["password"]
# }
#
# module "cloudflared" {
#   source    = "../vault-secret"
#   name      = "apps/cloudflared"
#   namespace = "cloudflared"
#   values    = {
#     token = data.vault_kv_secret_v2.bootstrap_inputs.data["cloudflare_token"]
#   }
# }
