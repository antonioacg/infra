# Networking Module Outputs

output "ingress_namespace" {
  description = "Nginx Ingress Controller namespace"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "ingress_class" {
  description = "Ingress class name"
  value       = var.ingress_class
}

output "ingress_controller_name" {
  description = "Nginx Ingress Controller release name"
  value       = helm_release.nginx_ingress.name
}

output "cloudflared_enabled" {
  description = "Whether Cloudflare tunnel is enabled"
  value       = var.enable_cloudflare_tunnel
}