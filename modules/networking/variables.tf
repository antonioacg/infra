# Networking Module Variables

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
  default     = "nginx"
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

variable "node_count" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 1
}

variable "enable_load_balancer" {
  description = "Enable LoadBalancer service type (when external load balancer is available)"
  type        = bool
  default     = false
}

variable "enable_cloudflare_tunnel" {
  description = "Enable Cloudflare tunnel for external access"
  type        = bool
  default     = false
}

variable "cloudflare_tunnel_token" {
  description = "Cloudflare tunnel token"
  type        = string
  default     = ""
  sensitive   = true
}