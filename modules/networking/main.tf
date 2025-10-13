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
      # HA mode: 2 replicas for multi-node clusters
      replicaCount = var.node_count > 1 ? 2 : 1

      service = {
        type = var.enable_load_balancer ? "LoadBalancer" : "ClusterIP"

        # Use NodePort for external access when not using load balancer
        nodePorts = var.enable_load_balancer ? {} : {
          http  = 30080
          https = 30443
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = var.resource_tier == "large" ? "1000m" : (var.resource_tier == "medium" ? "750m" : "500m")
          memory = var.resource_tier == "large" ? "512Mi" : (var.resource_tier == "medium" ? "384Mi" : "256Mi")
        }
      }

      # Enable metrics for enterprise tiers (medium/large)
      metrics = {
        enabled = contains(["medium", "large"], var.resource_tier)
        serviceMonitor = {
          enabled = contains(["medium", "large"], var.resource_tier)
        }
      }

      # High availability: spread replicas across nodes for multi-node clusters
      affinity = var.node_count > 1 ? {
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

        # Performance tuning based on tier
        worker-processes = var.resource_tier == "large" ? "auto" : "1"
        max-worker-connections = var.resource_tier == "large" ? "16384" : (var.resource_tier == "medium" ? "8192" : "1024")

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

    replicaCount = var.node_count > 1 ? 2 : 1

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