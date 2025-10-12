# Networking Module Variables

variable "ingress_class" {
  description = "Ingress class name"
  type        = string
  default     = "nginx"
}

variable "environment" {
  description = "Environment phase (homelab or business)"
  type        = string
  default     = "homelab"

  validation {
    condition     = contains(["homelab", "business"], var.environment)
    error_message = "Environment must be either 'homelab' or 'business'."
  }
}

variable "enable_load_balancer" {
  description = "Enable LoadBalancer service type (for business environments)"
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