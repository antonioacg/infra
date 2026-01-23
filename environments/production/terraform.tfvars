# Production Environment Configuration

# Environment name (production, staging, development)
environment = "production"

# Resource tier - controls resource allocation (small, medium, large)
resource_tier = "small" # Change to "medium" or "large" for more resources

# Scaling configuration - controls HA and distributed deployments
node_count = 1 # Increase to 3+ for multi-node HA

# Storage sizes (adjust based on available disk space)
vault_storage_size = "10Gi"
app_storage_size   = "20Gi"

# Secrets (provided via environment variables)
# export TF_VAR_github_token="ghp_xxx"
# export TF_VAR_cloudflare_tunnel_token="xxx"