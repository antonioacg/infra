# Production Environment Variables
# Infrastructure is now managed via Flux GitOps
# These variables are kept for state backend compatibility only

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be: production, staging, or development."
  }
}

# Note: The following variables have been removed as infrastructure
# is now managed via Flux GitOps:
# - node_count, resource_tier (tier-based scaling)
# - vault_storage_access_key, vault_storage_secret_key (Vault credentials)
# - postgres_password (PostgreSQL password)
# - github_org, git_ref, github_token (GitOps config)
# - cloudflare_tunnel_token (external access)
# - vault_storage_size, app_storage_size (storage config)
# - vault_secrets (secret management)
#
# These are now configured in the deployments repository or
# created as Kubernetes secrets by the bootstrap script.
