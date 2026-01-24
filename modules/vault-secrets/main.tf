data "vault_kv_secret_v2" "bootstrap_inputs" {
  mount = "secret"
  name  = "bootstrap/inputs"
}

# Example usage:
# module "redis" {
#   source    = "../vault-secret"
#   name      = "apps/redis"
#   namespace = "redis"
#   keys      = ["password"]
# }
