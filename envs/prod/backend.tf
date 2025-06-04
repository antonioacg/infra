terraform {
  backend "s3" {
    endpoint                    = var.minio_endpoint
    region                      = var.minio_region
    access_key                  = var.minio_access_key
    secret_key                  = var.minio_secret_key
    bucket                      = var.minio_bucket
    key                         = "prod/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
    force_path_style            = true
  }
}