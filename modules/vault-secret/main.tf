terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

resource "random_password" "auto_generated" {
  for_each = toset(var.keys)
  length   = 32
  special  = false
}

resource "vault_kv_secret_v2" "secret" {
  mount = var.vault_mount
  name  = var.name
  data_json = jsonencode(merge(
    { for k, v in random_password.auto_generated : k => v.result },
    var.values
  ))
}

locals {
  k8s_secret_name = var.secret_name != "" ? var.secret_name : basename(var.name)
}

resource "kubernetes_manifest" "external_secret" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = local.k8s_secret_name
      namespace = var.namespace
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "vault-backend"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = local.k8s_secret_name
        creationPolicy = "Owner"
      }
      dataFrom = [
        {
          extract = {
            key = "${var.vault_mount}/${var.name}"
          }
        }
      ]
    }
  }
}
