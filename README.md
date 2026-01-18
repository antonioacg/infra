# Infra Repository

Terraform configuration for Phase 2+ infrastructure.

**After bootstrap, all infrastructure changes are managed via Flux GitOps** (see `deployments/` repo).

## Purpose

This repo contains Terraform for:
- Phase 2: State migration + Flux installation (REMOTE state in MinIO)

**Note**: Phase 1 Terraform (MinIO, PostgreSQL) is in `infra-management/bootstrap-state/` with LOCAL state.

Post-Phase 2, Terraform is only used for state management. All infrastructure changes (Vault, ESO, ingress, apps) flow through `deployments/` via Flux.

## Structure

```
infra/
├── environments/
│   └── production/     # Phase 2+ config
│       ├── backend.tf  # Remote state (MinIO)
│       ├── main.tf     # Module invocations
│       └── variables.tf
└── modules/            # Reusable modules
```

## Prerequisites

- Terraform >= 1.0
- Phase 1 complete (k3s, MinIO, PostgreSQL running)
- State migration from LOCAL to REMOTE

## Usage

Terraform is invoked automatically by bootstrap scripts. Manual usage:

```bash
cd environments/production
terraform init
terraform plan
terraform apply
```

## State Management

| Phase | Location | Backend |
|-------|----------|---------|
| Phase 1 | `infra-management/bootstrap-state/` | LOCAL (`/tmp/bootstrap-state`) |
| Phase 2+ | `infra/environments/production/` | REMOTE (MinIO + PostgreSQL) |

## Post-Bootstrap

After Phase 2 completes:
- Terraform state is preserved in MinIO
- All changes to Vault, ESO, ingress, apps via `deployments/` repo
- Flux reconciles GitOps manifests automatically

## Related Documentation

- [ARCHITECTURE.md](../ARCHITECTURE.md) - Platform architecture
- [BOOTSTRAP.md](../infra-management/BOOTSTRAP.md) - Bootstrap phases
- [deployments/](../deployments/) - GitOps manifests
