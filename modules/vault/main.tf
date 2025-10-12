# Vault Infrastructure Deployment
# Handles Vault server installation and configuration

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  version    = "0.30.1"  # Avoid v0.30.0 which has templating issues

  create_namespace = false

  values = [yamlencode({
    server = {
      # High availability configuration
      ha = {
        enabled  = var.vault_ha_enabled
        replicas = var.vault_replicas
      }

      # Data storage configuration
      dataStorage = {
        enabled      = true
        size         = var.vault_storage_size
        storageClass = "local-path"
      }

      # Auto-initialization and unsealing
      extraInitContainers = [{
        name  = "vault-init"
        image = "vault:1.15.2"
        command = ["/bin/sh"]
        args = ["-c", file("${path.module}/scripts/vault-init.sh")]
        env = [{
          name = "VAULT_ADDR"
          value = "http://localhost:8200"
        }]
        volumeMounts = [{
          name      = "vault-data"
          mountPath = "/vault/data"
        }]
      }]

      # Server configuration
      standalone = {
        enabled = !var.vault_ha_enabled
        config = var.storage_backend == "s3" ? templatefile("${path.module}/config/vault-s3.hcl", {
          storage_config = var.storage_config
        }) : templatefile("${path.module}/config/vault-file.hcl", {})
      }

      # Resources - enterprise-grade scaling for production
      resources = {
        requests = {
          memory = contains(["production", "business"], var.environment) ? "512Mi" : "256Mi"
          cpu    = contains(["production", "business"], var.environment) ? "250m" : "100m"
        }
        limits = {
          memory = contains(["production", "business"], var.environment) ? "1Gi" : "512Mi"
          cpu    = contains(["production", "business"], var.environment) ? "1000m" : "500m"
        }
      }

      # Service configuration
      service = {
        enabled = true
        type    = "ClusterIP"
        port    = 8200
      }

      # UI configuration
      ui = {
        enabled         = true
        serviceType     = "ClusterIP"
        serviceNodePort = null
      }
    }

    # Injector configuration
    injector = {
      enabled = var.environment == "business"  # Enable in business phase for advanced features

      resources = {
        requests = {
          memory = "128Mi"
          cpu    = "50m"
        }
        limits = {
          memory = "256Mi"
          cpu    = "250m"
        }
      }
    }
  })]
}

# Service account for Vault auto-unseal
resource "kubernetes_service_account" "vault_unseal" {
  metadata {
    name      = "vault-unseal"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "vault_unseal" {
  metadata {
    name = "vault-unseal"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "create", "update", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "vault_unseal" {
  metadata {
    name = "vault-unseal"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.vault_unseal.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_unseal.metadata[0].name
    namespace = kubernetes_service_account.vault_unseal.metadata[0].namespace
  }
}

# Legacy secrets management (keeping for compatibility)
resource "vault_mount" "kv" {
  path = var.mount_path
  type = var.mount_type
  options = {
    version = var.mount_version
  }

  depends_on = [helm_release.vault]
}

resource "vault_kv_secret_v2" "secrets" {
  for_each = var.secrets

  mount = vault_mount.kv.path
  path  = each.key
  data  = each.value

  depends_on = [vault_mount.kv]
}