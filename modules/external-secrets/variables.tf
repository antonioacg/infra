# External Secrets Module Variables

variable "vault_endpoint" {
  description = "Vault server endpoint URL"
  type        = string
}

variable "vault_auth_role" {
  description = "Vault Kubernetes auth role for External Secrets"
  type        = string
  default     = "external-secrets"
}

variable "namespace" {
  description = "Namespace for External Secrets Operator"
  type        = string
  default     = "external-secrets-system"
}