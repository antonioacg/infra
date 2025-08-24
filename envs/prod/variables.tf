variable "minio_endpoint" {
  description = "MinIO endpoint URL"
  type        = string
}

variable "minio_region" {
  description = "MinIO region"
  type        = string
  default     = "us-east-1"
}

variable "minio_access_key" {
  description = "MinIO access key"
  type        = string
}

variable "minio_secret_key" {
  description = "MinIO secret key"
  type        = string
  sensitive   = true
}

variable "minio_bucket" {
  description = "MinIO bucket for Terraform state"
  type        = string
  default     = "terraform-state"
}

variable "vault_addr" {
  description = "Vault server address (e.g. https://vault.production.local)"
  type        = string
}

variable "vault_secrets" {
  description = "Map of Vault secret paths to key/value maps"
  type        = map(map(string))
  default     = {}
}

# Bootstrap secrets - provided via environment variables during Phase 2
variable "github_token" {
  description = "GitHub token for Flux authentication (required for fresh bootstrap)"
  type        = string
  default     = ""
  sensitive   = true
  
  validation {
    condition = length(var.github_token) == 0 || can(regex("^ghp_[a-zA-Z0-9]{36}$", var.github_token))
    error_message = "GitHub token must be empty (for ongoing ops) or valid personal access token starting with 'ghp_'."
  }
}

