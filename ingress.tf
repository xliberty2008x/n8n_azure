resource "kubernetes_ingress_v1" "n8n_ingress" {
  metadata {
    name      = "${random_pet.name_prefix.id}-ingress-n8n"
    namespace = kubernetes_namespace.n8n.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"           = "nginx"
      "cert-manager.io/cluster-issuer"          = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
    }
  }

  spec {
    rule {
      host = "n8n.big-sister.ai"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.n8n_service.metadata[0].name
              port {
                number = var.n8n_port
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = ["n8n.big-sister.ai"]
      secret_name = "n8n-tls-secret"   # cert-manager will automatically create/update this secret
    }
  }
}
