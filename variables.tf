variable "subscription_id" {
  description = "The subscription ID for the Azure account."
  type        = string
}

variable "client_id" {
  description = "The client ID for the Azure Service Principal."
  type        = string
}

variable "client_secret" {
  description = "The client secret for the Azure Service Principal."
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "The tenant ID for the Azure account."
  type        = string
}

variable "administrator_login" {
  description = "The administrator login for the PostgreSQL server."
  type        = string
}

variable "administrator_login_password" {
  description = "The administrator login password for the PostgreSQL server."
  type        = string
  sensitive   = true
}

variable "namespace" {
  description = "Define in which kubernetes namespace the PV will be created"
  type        = string
}

variable "pv_storage" {
  description = "The size of PV"
  type        = string
  default     = "2Gi"
}

variable "pv_access_modes" {
  description = "A set of the desired access modes the volume should have."
  type        = list(string)
  default     = ["ReadWriteOnce"]
}

variable "service_spec_type" {
  description = "Kubernetes service type"
  type        = string
  default     = "LoadBalancer"
}

variable "n8n_deployment_and_service_name" {
  description = "Name for the deployment and for service which will run n8n"
  type        = string
  default     = "n8n"
}

variable "claim0_persistent_volume_name" {
  description = "While not essential for running n8n, using persistent volumes helps maintain files uploaded while using n8n and if you want to persist manual n8n encryption keys between restarts, which saves a file containing the key into file storage during startup."
  type        = string
  default     = "n8n-claim0"
}

variable "n8n_protocol" {
  description = "n8n protocol to be used"
  type        = string
  default     = "http"
}

variable "n8n_port" {
  description = "n8n port to be exposed"
  type        = string
  default     = "5678"
}

variable "postgres_port" {
  description = "Port used to access postgres database"
  type        = number
  default     = 5432
}

variable "postgres_database" {
  description = "The database name that will be created"
  type        = string
}

variable "postgres_username" {
  description = "Master db user username"
  type        = string
}

variable "postgres_password" {
  description = "Master db user password"
  type        = string
}

variable "PGHOST" {
  description = "PostgreSQL host address"
  type        = string
}