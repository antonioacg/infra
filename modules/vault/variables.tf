variable "mount_path" {
  description = "Mount path for KV engine"
  type        = string
  default     = "secret"
}

variable "mount_type" {
  description = "Engine type"
  type        = string
  default     = "kv"
}

variable "mount_version" {
  description = "KV engine version"
  type        = number
  default     = 2
}

variable "secrets" {
  description = "Map of secret paths to key/value pairs"
  type        = map(map(string))
}