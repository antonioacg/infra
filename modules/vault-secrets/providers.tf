terraform {
  required_providers {
    vault      = { source = "hashicorp/vault", version = "~> 4.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
    random     = { source = "hashicorp/random", version = "~> 3.0" }
  }
}

# Vault provider uses K8s auth via service account token
# tf-controller mounts the SA token automatically
provider "vault" {
  address         = var.vault_addr
  skip_tls_verify = true # Self-signed cert in homelab

  auth_login {
    path = "auth/kubernetes/login"
    parameters = {
      role = "tf-controller"
      jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
    }
  }
}

# Kubernetes provider uses in-cluster config
provider "kubernetes" {
  # tf-controller runs in-cluster, uses default SA
}
