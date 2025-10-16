# terraform.tfvars
#
# All variables are provided via environment variables in GitHub Actions workflow.
# See .github/workflows/apply-python-taskrunner-external.yml for the actual values.
#
# The workflow dynamically fetches values from Azure:
# - subscription_id: from `az account show`
# - namespace: hardcoded as "n8n"
# - postgres_database: hardcoded as "n8n"
# - postgres_username: hardcoded as "n8nadmin"
# - administrator_login: hardcoded as "n8nadmin"
# - PGHOST: from `az postgres flexible-server show`
#
# Only these require GitHub secrets (sensitive):
# - administrator_login_password: from secret TF_VAR_ADMINISTRATOR_LOGIN_PASSWORD
# - postgres_password: from secret TF_VAR_POSTGRES_PASSWORD
#
# ============================================================================
# FOR LOCAL DEVELOPMENT ONLY
# ============================================================================
# Uncomment and fill in these values if running Terraform locally:
#
# # Azure credentials
# subscription_id = "your-azure-subscription-id"
# client_id       = "your-service-principal-client-id"
# client_secret   = "your-service-principal-client-secret"
# tenant_id       = "your-azure-tenant-id"
#
# # PostgreSQL configuration
# administrator_login          = "n8nadmin"
# administrator_login_password = "your-postgres-admin-password"
# postgres_username            = "n8nadmin"
# postgres_password            = "your-postgres-user-password"
# postgres_database            = "n8n"
# PGHOST                       = "your-postgres-server.postgres.database.azure.com"
#
# # Kubernetes configuration
# namespace = "n8n"
#
# # Optional overrides (these have defaults in variables.tf)
# # n8n_deployment_and_service_name = "n8n"
# # claim0_persistent_volume_name   = "n8n-claim0"
# # n8n_protocol                    = "http"
# # n8n_port                        = "5678"
# # postgres_port                   = 5432
# # service_spec_type               = "LoadBalancer"
