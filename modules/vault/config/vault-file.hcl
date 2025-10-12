# Vault File Storage Configuration

ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "file" {
  path = "/vault/data"
}

api_addr     = "http://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

# Performance and security settings
default_lease_ttl = "768h"
max_lease_ttl     = "8760h"