terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0" # Ensure you are using a version that supports auth_login kubernetes
    }
  }
}

provider "vault" {
  address = var.vault_addr

  # Add Kubernetes auth method
  auth_login {
    path = "auth/kubernetes/login"
    parameters = {
      role = "terraform" # This should match the role_name in your vault-auth module
      jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
    }
  }
}