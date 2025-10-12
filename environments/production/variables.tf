# Production Environment Variables

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["production", "staging", "development"], var.environment)
    error_message = "Environment must be: production, staging, or development."
  }
}

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1  # homelab default, override to 3+ for business
}

variable "resource_tier" {
  description = "Resource tier for scaling (small, medium, large)"
  type        = string
  default     = "small"

  validation {
    condition     = contains(["small", "medium", "large"], var.resource_tier)
    error_message = "Resource tier must be: small, medium, or large."
  }
}

variable "vault_secrets" {
  description = "Map of Vault secret paths to key/value maps"
  type        = map(map(string))
  default     = {}
  sensitive   = true
}

# Bootstrap secrets - provided via environment variables from Phase 1
variable "vault_storage_access_key" {
  description = "MinIO access key for Vault storage (from Phase 1)"
  type        = string
  sensitive   = true
}

variable "vault_storage_secret_key" {
  description = "MinIO secret key for Vault storage (from Phase 1)"
  type        = string
  sensitive   = true
}

variable "postgres_password" {
  description = "PostgreSQL password for state locking (from Phase 1)"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub organization for module sources"
  type        = string
  default     = "antonioacg"
}

variable "git_ref" {
  description = "Git reference for module sources"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub token for Flux authentication"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition = length(var.github_token) == 0 || can(regex("^ghp_[a-zA-Z0-9]{36}$", var.github_token))
    error_message = "GitHub token must be empty or valid personal access token starting with 'ghp_'."
  }
}

variable "cloudflare_tunnel_token" {
  description = "Cloudflare tunnel token for external access"
  type        = string
  default     = ""
  sensitive   = true
}

# Storage configuration
variable "vault_storage_size" {
  description = "Storage size for Vault data"
  type        = string
  default     = "10Gi"
}

variable "app_storage_size" {
  description = "Storage size for applications"
  type        = string
  default     = "20Gi"
}