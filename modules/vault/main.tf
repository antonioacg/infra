resource "vault_mount" "kv" {
  path = var.mount_path
  type = var.mount_type
  options = {
    version = var.mount_version
  }
}

resource "vault_kv_secret_v2" "secrets" {
  for_each = var.secrets

  mount = vault_mount.kv.path
  path  = each.key
  data  = each.value
}