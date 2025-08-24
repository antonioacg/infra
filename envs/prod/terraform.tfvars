# Terraform variables for production environment

# Self-hosted MinIO in k3s (service: minio in vault namespace)
minio_endpoint   = "http://minio.vault.svc.cluster.local:9000"
minio_region     = "us-east-1"
minio_access_key = "YOUR_MINIO_ACCESS_KEY"
minio_secret_key = "YOUR_MINIO_SECRET_KEY"

# Vault API address
vault_addr  = "https://vault.production.local"

# Define KV-v2 secrets as path => (key => value) map
vault_secrets = {
  "app/config" = {
    "username" = "appuser"
    "password" = "apppass"
  }

  "db/credentials" = {
    "username" = "dbuser"
    "password" = "dbpass"
  }
}