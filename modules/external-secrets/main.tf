# External Secrets Operator Module
# Manages External Secrets Operator installation and configuration

resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets-system"
  }
}

resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name
  version    = "0.9.11"

  create_namespace = false

  values = [yamlencode({
    installCRDs = true

    replicaCount = 1

    resources = {
      requests = {
        cpu    = "100m"
        memory = "128Mi"
      }
      limits = {
        cpu    = "500m"
        memory = "256Mi"
      }
    }

    securityContext = {
      allowPrivilegeEscalation = false
      readOnlyRootFilesystem   = true
      runAsNonRoot             = true
      runAsUser                = 65532
      capabilities = {
        drop = ["ALL"]
      }
    }

    serviceAccount = {
      create = true
      name   = "external-secrets-operator"
    }
  })]
}

# Service account for Vault authentication
resource "kubernetes_service_account" "vault_auth" {
  metadata {
    name      = "external-secrets-vault"
    namespace = kubernetes_namespace.external_secrets.metadata[0].name
    annotations = {
      "vault.hashicorp.com/auth-path" = "auth/kubernetes"
      "vault.hashicorp.com/role"     = var.vault_auth_role
    }
  }
}

# ClusterRole for External Secrets to read secrets
resource "kubernetes_cluster_role" "external_secrets_vault" {
  metadata {
    name = "external-secrets-vault"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external_secrets_vault" {
  metadata {
    name = "external-secrets-vault"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.external_secrets_vault.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_auth.metadata[0].name
    namespace = kubernetes_service_account.vault_auth.metadata[0].namespace
  }
}

# ClusterSecretStore for Vault integration
resource "kubernetes_manifest" "vault_cluster_secret_store" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "vault-backend"
    }
    spec = {
      provider = {
        vault = {
          server = var.vault_endpoint
          path   = "secret"
          version = "v2"
          auth = {
            kubernetes = {
              mountPath = "kubernetes"
              role      = var.vault_auth_role
              serviceAccountRef = {
                name      = kubernetes_service_account.vault_auth.metadata[0].name
                namespace = kubernetes_service_account.vault_auth.metadata[0].namespace
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.external_secrets]
}