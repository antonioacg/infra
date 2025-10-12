# Production Environment Configuration
# Adjust these values based on deployment phase

# Environment phase - controls resource allocation and features
environment = "homelab"  # Change to "business" for multi-node deployment

# Scaling configuration
node_count = 1  # Increase to 3+ for business phase

# Storage sizes (adjust based on available disk space)
vault_storage_size = "10Gi"
app_storage_size   = "20Gi"

# Secrets (provided via environment variables)
# export TF_VAR_github_token="ghp_xxx"
# export TF_VAR_cloudflare_tunnel_token="xxx"