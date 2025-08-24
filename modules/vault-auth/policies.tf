resource "vault_policy" "terraform" {
  name = "terraform"
  policy = <<EOT
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/metadata/*" {
  capabilities = ["list", "read"]
}

# Allow managing KV v2 secrets engines, if you create them dynamically
# path "sys/mounts/secret/*" {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }

# Allow managing auth methods - be very careful with these permissions
# path "auth/kubernetes/*" {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }

# Allow managing policies - be very careful with these permissions
# path "sys/policies/acl/*" {
#   capabilities = ["create", "read", "update", "delete", "list"]
# }
EOT
}
