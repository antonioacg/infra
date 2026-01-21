# Production Environment Outputs
# Infrastructure is now managed via Flux GitOps
# Module outputs have been removed

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Note: The following outputs have been removed as infrastructure
# is now managed via Flux GitOps:
# - vault_endpoint, vault_namespace (from vault module)
# - external_secrets_namespace (from external_secrets module)
# - ingress_controller_namespace (from networking module)
# - node_count (tier-based scaling)
#
# To check infrastructure status, use:
#   flux get helmreleases -A
#   kubectl get pods -A
