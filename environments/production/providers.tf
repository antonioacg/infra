# Production Environment Providers

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "vault" {
  address = "http://localhost:8200"  # Port-forward to Vault

  # Use Kubernetes service account authentication
  auth_login {
    path = "auth/kubernetes/login"
    parameters = {
      role = "terraform"
      jwt  = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
    }
  }
}