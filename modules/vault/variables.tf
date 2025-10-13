# Vault Module Variables

variable "environment" {
  description = "Environment name (production, staging, development, homelab, business)"
  type        = string
  default     = "homelab"

  validation {
    condition     = contains(["production", "staging", "development", "homelab", "business"], var.environment)
    error_message = "Environment must be: production, staging, development, homelab, or business."
  }
}

variable "storage_backend" {
  description = "Vault storage backend type (file or s3)"
  type        = string
  default     = "s3"

  validation {
    condition     = contains(["file", "s3"], var.storage_backend)
    error_message = "Storage backend must be either 'file' or 's3'."
  }
}

variable "storage_config" {
  description = "Storage backend configuration"
  type = object({
    endpoint   = optional(string)
    bucket     = optional(string)
    access_key = optional(string)
    secret_key = optional(string)
  })
  default = {}
}

variable "vault_ha_enabled" {
  description = "Enable Vault high availability mode"
  type        = bool
  default     = false
}

variable "vault_replicas" {
  description = "Number of Vault replicas for HA mode"
  type        = number
  default     = 1
}

variable "vault_storage_size" {
  description = "Storage size for Vault data"
  type        = string
  default     = "10Gi"
}

variable "vault_resources" {
  description = "Resource allocation for Vault pods (requests and limits)"
  type = object({
    requests = object({
      memory = string
      cpu    = string
    })
    limits = object({
      memory = string
      cpu    = string
    })
  })
  default = {
    requests = {
      memory = "256Mi"
      cpu    = "100m"
    }
    limits = {
      memory = "512Mi"
      cpu    = "500m"
    }
  }
}

# Note: Legacy secrets management variables removed.
# KV secrets engine is configured via Bank-Vaults externalConfig.
# Application secrets should be managed via External Secrets Operator (Phase 3+).