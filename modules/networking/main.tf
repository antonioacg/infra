# Networking Module
# Manages Nginx Ingress Controller and networking infrastructure

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = "4.8.3"

  create_namespace = false

  values = [yamlencode({
    controller = {
      replicaCount = var.environment == "business" ? 2 : 1

      service = {
        type = var.enable_load_balancer ? "LoadBalancer" : "ClusterIP"

        # For homelab phase, use NodePort for external access
        nodePorts = var.environment == "homelab" ? {
          http  = 30080
          https = 30443
        } : {}
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = var.environment == "business" ? "1000m" : "500m"
          memory = var.environment == "business" ? "512Mi" : "256Mi"
        }
      }

      # Enable metrics for monitoring in business phase
      metrics = {
        enabled = var.environment == "business"
        serviceMonitor = {
          enabled = var.environment == "business"
        }
      }

      # High availability configuration for business phase
      affinity = var.environment == "business" ? {
        podAntiAffinity = {
          preferredDuringSchedulingIgnoredDuringExecution = [{
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchExpressions = [{
                  key      = "app.kubernetes.io/name"
                  operator = "In"
                  values   = ["ingress-nginx"]
                }]
              }
              topologyKey = "kubernetes.io/hostname"
            }
          }]
        }
      } : {}

      config = {
        # Security headers
        add-headers = "ingress-nginx/custom-headers"

        # Performance tuning
        worker-processes = var.environment == "business" ? "auto" : "1"
        max-worker-connections = var.environment == "business" ? "16384" : "1024"

        # SSL configuration
        ssl-protocols = "TLSv1.2 TLSv1.3"
        ssl-ciphers = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256"
      }
    }

    defaultBackend = {
      enabled = true
      replicaCount = 1
    }
  })]
}

# ConfigMap for custom headers
resource "kubernetes_config_map" "custom_headers" {
  metadata {
    name      = "custom-headers"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }

  data = {
    "X-Frame-Options"        = "DENY"
    "X-Content-Type-Options" = "nosniff"
    "X-XSS-Protection"       = "1; mode=block"
    "Referrer-Policy"        = "strict-origin-when-cross-origin"
  }
}

# Cloudflare tunnel for external access (optional)
resource "helm_release" "cloudflared" {
  count = var.enable_cloudflare_tunnel ? 1 : 0

  name       = "cloudflared"
  repository = "https://cloudflare.github.io/helm-charts"
  chart      = "cloudflared"
  namespace  = "cloudflare"
  version    = "0.3.0"

  create_namespace = true

  values = [yamlencode({
    cloudflared = {
      token = var.cloudflare_tunnel_token
    }

    replicaCount = var.environment == "business" ? 2 : 1

    resources = {
      requests = {
        cpu    = "50m"
        memory = "64Mi"
      }
      limits = {
        cpu    = "200m"
        memory = "128Mi"
      }
    }
  })]
}