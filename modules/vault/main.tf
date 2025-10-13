# Vault Infrastructure Deployment with Bank-Vaults Operator
# Handles Vault server installation and configuration via Bank-Vaults operator

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_namespace" "vault_operator" {
  metadata {
    name = "vault-operator"
  }
}

# Bank-Vaults Operator Installation
resource "helm_release" "vault_operator" {
  name       = "vault-operator"
  repository = "oci://ghcr.io/bank-vaults/helm-charts"
  chart      = "vault-operator"
  namespace  = kubernetes_namespace.vault_operator.metadata[0].name
  version    = "1.22.2"  # Latest stable version

  create_namespace = false

  set {
    name  = "image.tag"
    value = "v1.22.2"
  }
}

# Vault CR (Custom Resource) managed by Bank-Vaults operator
resource "kubernetes_manifest" "vault" {
  manifest = {
    apiVersion = "vault.banzaicloud.com/v1alpha1"
    kind       = "Vault"
    metadata = {
      name      = "vault"
      namespace = kubernetes_namespace.vault.metadata[0].name
    }
    spec = {
      size  = var.vault_replicas
      image = "hashicorp/vault:1.15.2"

      # Kubernetes Secrets-based unsealing (protected by Phase 1 etcd encryption)
      unsealConfig = {
        kubernetes = {
          secretNamespace = kubernetes_namespace.vault.metadata[0].name
          secretName      = "vault-unseal-keys"
        }
        options = {
          preFlightChecks = true
          storeRootToken  = true  # Store for bootstrap, revoke after
          secretShares    = 5
          secretThreshold = 3
        }
      }

      # Vault server configuration
      config = {
        api_addr     = "http://vault.${kubernetes_namespace.vault.metadata[0].name}.svc.cluster.local:8200"
        cluster_addr = "http://vault.${kubernetes_namespace.vault.metadata[0].name}.svc.cluster.local:8201"

        listener = [{
          tcp = {
            address     = "0.0.0.0:8200"
            tls_disable = true  # TLS termination at ingress (Phase 4)
          }
        }]

        storage = var.storage_backend == "s3" ? {
          s3 = {
            endpoint            = var.storage_config.endpoint
            bucket              = var.storage_config.bucket
            region              = "us-east-1"  # MinIO requires region
            disable_ssl         = "true"
            s3_force_path_style = "true"  # Required for MinIO
            access_key          = var.storage_config.access_key
            secret_key          = var.storage_config.secret_key
          }
        } : {
          file = {
            path = "/vault/data"
          }
        }

        ui = true
      }

      # Automatic Vault configuration after initialization
      externalConfig = {
        # Enable Kubernetes auth backend
        auth = [{
          type = "kubernetes"
          path = "kubernetes"
          config = {
            kubernetes_host = "https://kubernetes.default.svc"
          }
          roles = [{
            name = "external-secrets"
            bound_service_account_names = [
              "external-secrets"
            ]
            bound_service_account_namespaces = [
              "external-secrets-system"
            ]
            policies = [
              "external-secrets"
            ]
            ttl = "1h"
          }]
        }]

        # Policies for External Secrets
        policies = [{
          name = "external-secrets"
          rules = <<-EOT
            path "secret/data/*" {
              capabilities = ["read", "list"]
            }
            path "secret/metadata/*" {
              capabilities = ["read", "list"]
            }
          EOT
        }]

        # Enable KV v2 secrets engine
        secrets = [{
          type        = "kv"
          path        = "secret"
          description = "KV v2 secrets engine"
          options = {
            version = 2
          }
        }]
      }

      # Resource allocation (tier-based via variables)
      resources = {
        vault = var.vault_resources
      }

      # Service configuration
      serviceType = "ClusterIP"

      # Monitoring (enable in Phase 3)
      serviceMonitorEnabled = false

      # Volume for audit logs
      volumeClaimTemplates = [{
        metadata = {
          name = "vault-audit"
        }
        spec = {
          accessModes = ["ReadWriteOnce"]
          resources = {
            requests = {
              storage = "10Gi"
            }
          }
        }
      }]
    }
  }

  depends_on = [helm_release.vault_operator]
}

# Note: KV secrets engine and secrets are now managed via Bank-Vaults
# externalConfig (see Vault CR configuration above). Legacy vault_mount
# and vault_kv_secret_v2 resources have been removed to avoid requiring
# the Vault provider during Phase 2c deployment.
#
# Secrets should be managed via:
# 1. Bank-Vaults externalConfig for secrets engine setup (done above)
# 2. External Secrets Operator for application secret synchronization (Phase 3+)
# 3. Direct Vault CLI/API for manual secret management (Phase 3+)
