output "vault_path" {
  value = "${var.vault_mount}/${var.name}"
}

output "k8s_secret_name" {
  value = basename(var.name)
}
