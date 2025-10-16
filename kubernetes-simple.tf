##############################
# AKS Cluster
##############################

resource "azurerm_kubernetes_cluster" "main" {
  name                = "n8nAKScluster"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "myaks"

  default_node_pool {
    name           = "n8n1node"
    node_count     = 2
    vm_size        = "Standard_B2s"
    os_disk_type   = "Managed"
    type           = "VirtualMachineScaleSets"
    #vnet_subnet_id = azurerm_subnet.subnetA.id
  }

  identity {
    type = "SystemAssigned"
  }

  // network_profile {
  //   dns_service_ip    = "10.2.0.10"
  //   service_cidr      = "10.2.0.0/16"
  //   load_balancer_sku = "standard"
  //   network_plugin    = "azure"
  //   network_policy    = "calico"
  //   outbound_type     = "loadBalancer"
  // }

  tags = {
    environment = "production"
  }
}

##############################
# Kubernetes Namespace
##############################
resource "kubernetes_namespace" "n8n" {
  metadata {
    name = var.namespace
  }
  depends_on = [azurerm_kubernetes_cluster.main]
}

##############################
# Cluster Role Binding for AKS Admin Access
##############################
resource "kubernetes_cluster_role_binding" "aks_admin" {
  depends_on = [azurerm_kubernetes_cluster.main]

  metadata {
    name = "aks-admin-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    api_group = ""
  }
}

##############################
# Kubernetes Deployment for n8n
##############################
##############################
# Kubernetes Secret for PostgreSQL CA Certificate
##############################
resource "kubernetes_secret" "postgres_ssl_cert" {
  metadata {
    name      = "postgres-ca-cert"
    namespace = kubernetes_namespace.n8n.metadata[0].name
  }
  data = {
    # Replace the file path with your local path to the CA PEM file.
    "BaltimoreCyberTrustRoot.crt.pem" = base64encode(file("/Users/cyrildubovik/Python_projects/n8n/BaltimoreCyberTrustRoot.crt.pem"))
  }
  type = "Opaque"
}

##############################
# Kubernetes Deployment for n8n
##############################
resource "kubernetes_deployment" "n8n_deployment" {
  metadata {
    name      = var.n8n_deployment_and_service_name
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      service = var.n8n_deployment_and_service_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        service = var.n8n_deployment_and_service_name
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          service = var.n8n_deployment_and_service_name
        }
      }

      spec {
        init_container {
          name  = "volume-permissions"
          image = "busybox:1.36"
          command = ["sh", "-c", "chown 1000:1000 /data"]

          volume_mount {
            name       = var.claim0_persistent_volume_name
            mount_path = "/data"
          }
        }

        container {
          name  = var.n8n_deployment_and_service_name
          image = "n8nio/n8n"
          command = ["/bin/sh"]
          args    = ["-c", "sleep 5; n8n start"]

          env {
            name  = "N8N_PROTOCOL"
            value = var.n8n_protocol
          }
          env {
            name = "N8N_HOST"
            value = "your_host_here"
          }
          env {
            name = "N8N_SECURE_COOKIE"
            value = "false"
          }
          env {
            name  = "N8N_PORT"
            value = var.n8n_port
          }
          env {
            name = "N8N_USER_FOLDER"
            value = "/home/node/.n8n"
          }
          env {
            name  = "DB_TYPE"
            value = "postgresdb"
          }
          env {
            name  = "DB_POSTGRESDB_HOST"
            value = azurerm_postgresql_flexible_server.main.fqdn
          }
          env {
            name  = "DB_POSTGRESDB_PORT"
            value = "5432"
          }
          env {
            name  = "DB_POSTGRESDB_DATABASE"
            value = "n8n"
          }
          env {
            name = "DB_POSTGRESDB_USER"
            value = var.postgres_username
          }
          env {
            name = "DB_POSTGRESDB_PASSWORD"
            value = var.postgres_password
          }
          # New environment variable to tell the connection to use the mounted CA certificate.
          env {
            name  = "DB_POSTGRESDB_SSL_CA"
            value = "/certs/BaltimoreCyberTrustRoot.crt.pem"
          }
          env {
            name = "DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED"
            value = "false"
          }
          env {
            name = "WEBHOOK_URL"
            value = "https://your_host"
          }
          # Python Task Runner Configuration
          env {
            name  = "N8N_RUNNERS_ENABLED"
            value = "true"
          }
          env {
            name  = "N8N_RUNNERS_MODE"
            value = "internal"
          }
          env {
            name  = "N8N_NATIVE_PYTHON_RUNNER"
            value = "true"
          }
          env {
            name  = "N8N_RUNNERS_STDLIB_ALLOW"
            value = "os,sys,json,re,datetime,math,time,random,hashlib,base64,collections,itertools"
          }
          env {
            name  = "N8N_RUNNERS_EXTERNAL_ALLOW"
            value = "pandas,numpy,requests,beautifulsoup4,lxml,openpyxl,pypdf,pillow,python-dateutil,pytz"
          }
          env {
            name  = "NODE_FUNCTION_ALLOW_BUILTIN"
            value = "*"
          }

          port {
            container_port = var.n8n_port
          } 

          resources {
            requests = {
              memory = "512Mi"
            }
            limits = {
              memory = "1Gi"
            }
          }

          volume_mount {
            name       = var.claim0_persistent_volume_name
            mount_path = "/home/node/.n8n"
          }
          # Mount the secret volume containing the CA certificate
          volume_mount {
            name       = "postgres-ca-cert"
            mount_path = "/certs"
            read_only  = true
          }
        }

        restart_policy = "Always"

        volume {
          name = var.claim0_persistent_volume_name
          persistent_volume_claim {
            claim_name = var.claim0_persistent_volume_name
          }
        }

        volume {
          name = "n8n-secret"
          secret {
            secret_name = "n8n-secret"
          }
        }
        # Define a new volume for the CA certificate secret.
        volume {
          name = "postgres-ca-cert"
          secret {
            secret_name = kubernetes_secret.postgres_ssl_cert.metadata[0].name
          }
        }
      }
    }
  }
}

##############################
# Kubernetes Service for n8n
##############################
resource "kubernetes_service" "n8n_service" {
  metadata {
    name      = var.n8n_deployment_and_service_name
    namespace = kubernetes_namespace.n8n.metadata[0].name
    labels = {
      app = var.n8n_deployment_and_service_name
    }
  }

  spec {
    selector = {
      service = var.n8n_deployment_and_service_name  # Changed from "app" to "service"
    }

    port {
      port        = var.n8n_port
      target_port = 5678
    }

    type = var.service_spec_type
  }
}
