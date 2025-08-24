variable "role_name" {
  description = "The name of the Kubernetes auth backend role."
  type        = string
  default     = "terraform"
}

variable "bound_service_account_names" {
  description = "List of service account names able to access this role."
  type        = list(string)
  default     = ["terraform"]
}

variable "bound_service_account_namespaces" {
  description = "List of namespaces that service accounts are allowed to access this role from."
  type        = list(string)
  default     = ["vault"] # Assuming the terraform SA is in the 'vault' namespace
}

variable "token_ttl" {
  description = "The TTL period of tokens issued using this role."
  type        = number
  default     = 3600 # 1 hour
}

variable "policy_name" {
  description = "The name of the Vault policy to attach to tokens issued by this role."
  type        = string
  default     = "terraform"
}
