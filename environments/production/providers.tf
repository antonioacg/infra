# Production Environment Providers

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Note: Vault provider not needed for Phase 2 deployment.
# Bank-Vaults handles all Vault configuration via externalConfig.
# Vault provider may be added back in Phase 3 if needed for advanced configuration.