# Production Environment Main Configuration
# Manages all infrastructure components using modules

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

# Tier-based resource scaling calculations
locals {
  # Determine if this is an enterprise tier (medium/large)
  is_enterprise_tier = contains(["medium", "large"], var.resource_tier)

  # Vault resource scaling based on tier (HA always enabled for enterprise readiness)
  vault_resources = {
    small = {
      requests = { memory = "256Mi", cpu = "100m" }
      limits   = { memory = "512Mi", cpu = "500m" }
    }
    medium = {
      requests = { memory = "512Mi", cpu = "250m" }
      limits   = { memory = "1Gi", cpu = "1000m" }
    }
    large = {
      requests = { memory = "1Gi", cpu = "500m" }
      limits   = { memory = "2Gi", cpu = "2000m" }
    }
  }

  # Vault replicas: minimum 3 for HA quorum, maximum based on node count
  vault_replicas = max(var.node_count, 3)
}

# Vault infrastructure and configuration
module "vault" {
  source = "../../modules/vault"

  environment          = var.environment
  storage_backend      = "s3"
  storage_config = {
    endpoint   = "http://bootstrap-minio.bootstrap.svc.cluster.local:9000"
    bucket     = "vault-storage"
    access_key = var.vault_storage_access_key
    secret_key = var.vault_storage_secret_key
  }

  # Enterprise-ready: HA always enabled with tier-based resource scaling
  vault_replicas     = local.vault_replicas
  vault_ha_enabled   = true  # Always enabled for enterprise validation
  vault_resources    = local.vault_resources[var.resource_tier]
}

# External Secrets Operator
module "external_secrets" {
  source = "../../modules/external-secrets"

  vault_endpoint = module.vault.endpoint
  vault_auth_role = "external-secrets"

  depends_on = [module.vault]
}

# Networking infrastructure
module "networking" {
  source = "../../modules/networking"

  ingress_class = "nginx"
  environment   = var.environment

  # Business phase gets additional networking features
  enable_load_balancer = var.environment == "business"
}

# Vault secrets and authentication setup
module "vault_auth" {
  source = "../../modules/vault-auth"

  vault_endpoint = module.vault.endpoint

  # Configure authentication backends and policies
  auth_backends = [
    {
      name = "kubernetes"
      type = "kubernetes"
      config = {
        kubernetes_host = "https://kubernetes.default.svc"
      }
    }
  ]

  depends_on = [module.vault]
}