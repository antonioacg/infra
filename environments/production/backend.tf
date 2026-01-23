# Production Environment Backend Configuration
# Uses bootstrap MinIO for remote state storage
# Credentials provided via environment variables or -backend-config

terraform {
  backend "s3" {
    # REQUIRES port-forward: kubectl port-forward -n bootstrap svc/bootstrap-minio 9000:9000 &
    # See CLAUDE.md "Day-2 Terraform Operations" for full setup
    endpoint = "http://localhost:9000"
    region   = "local" # MinIO accepts any string
    bucket   = "terraform-state"
    # key will be provided via -backend-config="key=${ENVIRONMENT}/infra/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true # Required for MinIO compatibility
    force_path_style            = true

    # Credentials provided via:
    # - AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables, OR
    # - terraform init -backend-config="access_key=..." -backend-config="secret_key=..."
  }
}