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

# The tf-minio-credentials ExternalSecret is managed by GitOps, not Terraform
# It's defined in deployments/clusters/production/tf-controller/tf-minio-externalsecret.yaml
# The secret will be created by the ExternalSecrets controller

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
