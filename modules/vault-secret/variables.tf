variable "name" {
  description = "Name of the secret in Vault and Kubernetes"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the ExternalSecret"
  type        = string
}

variable "keys" {
  description = "List of keys to auto-generate (random_password)"
  type        = list(string)
  default     = []
}

variable "values" {
  description = "Map of key-value pairs (user-provided secrets)"
  type        = map(string)
  default     = {}
}

variable "vault_mount" {
  description = "Vault mount path"
  type        = string
  default     = "secret"
}

variable "secret_name" {
  description = "Override the Kubernetes secret name (defaults to basename of name)"
  type        = string
  default     = ""
}
