resource "random_string" "aks_temporary_name" {
  length  = 8         # Azure requires 1-12 chars
  lower   = true
  upper   = false
  special = false
  numeric = true
}


resource "random_password" "pass" {
  length = 20
}

resource "random_pet" "name_prefix" {
  prefix = var.namespace
  length = 1
}

##############################
# Wait for AKS to be ready (hacky pause)
##############################
resource "null_resource" "wait_for_aks" {
  provisioner "local-exec" {
    command = "sleep 180"  // Increased wait to 3 minutes
  }
}