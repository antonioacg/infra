module "vault" {
  source  = "../../modules/vault"

  # pass in the map of secrets defined in vars
  secrets = var.vault_secrets
}