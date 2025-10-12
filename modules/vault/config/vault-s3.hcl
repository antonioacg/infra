# Vault S3 Storage Configuration

ui = true

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = true
}

storage "s3" {
  endpoint   = "${storage_config.endpoint}"
  bucket     = "${storage_config.bucket}"
  access_key = "${storage_config.access_key}"
  secret_key = "${storage_config.secret_key}"
  region     = "us-east-1"

  s3_force_path_style = true
}

api_addr     = "http://0.0.0.0:8200"
cluster_addr = "https://0.0.0.0:8201"

# Performance and security settings
default_lease_ttl = "768h"
max_lease_ttl     = "8760h"