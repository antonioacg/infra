# Production Environment Main Configuration
# Infrastructure components are now managed via Flux GitOps (deployments repository)
# This file only contains Terraform version requirements for state backend compatibility

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

# Note: Infrastructure modules have been migrated to GitOps
#
# The following components are now managed in the deployments repository:
# - Vault Operator (clusters/production/vault-operator/)
# - Vault (clusters/production/vault/)
# - External Secrets (clusters/production/external-secrets/)
# - Ingress Nginx (clusters/production/ingress-nginx/)
#
# This Terraform configuration now only manages the state backend.
# See: https://github.com/antonioacg/deployments/tree/main/clusters/production
