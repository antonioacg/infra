# Infra Repository

Terraform configuration for managing HashiCorp Vault secrets in the production k3s cluster.

## Structure

- **envs/prod**: environment-specific Terraform (backend, providers, module invocation, variables, tfvars)
- **modules/vault**: reusable Terraform module for mounting a KV-v2 engine and creating secrets

## Prerequisites

- Terraform >= 1.0 installed
- Kubernetes cluster (k3s) with Vault and MinIO deployed in `vault` namespace
- `kubectl` context configured for the production cluster
- Vault deployed with Bank-Vaults operator (automated unsealing managed by Phase 2 bootstrap)

## Setup & Usage

1. Update `envs/prod/terraform.tfvars` with your MinIO and Vault credentials, and define `vault_secrets`.

2. Initialize Terraform:
   ```bash
   cd envs/prod
   terraform init
   ```

3. Plan and apply:
   ```bash
   terraform plan -var-file=terraform.tfvars
   terraform apply -var-file=terraform.tfvars
   ```

4. Verify secrets in Vault:
   ```bash
   vault kv get -mount=secret <path>
   ```

## CI/CD

Automation can be added via Flux/CD or GitHub Actions to run Terraform commands on commits to `envs/prod`.

## License

MIT