output "mount_path" {
  description = "Path where the KV engine is mounted"
  value       = vault_mount.kv.path
}

output "secret_paths" {
  description = "List of secret paths created"
  value       = keys(vault_kv_secret_v2.secrets)
}