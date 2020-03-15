resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app  = "wordpress"
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_persistent_volume_claim" "wordpress" {
  metadata {
    name = "wp-pv-claim"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    # volume_name = kubernetes_persistent_volume.wordpress.metadata[0].name
  }
}

resource "kubernetes_deployment" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app  = "wordpress"
      }
    }
    template {
      metadata {
        labels = {
          app = "wordpress"
        }
      }
      spec {
        container {
          image = "wordpress:${var.wordpress_version}-apache"
          name  = "wordpress"

          resources {
            limits {
              cpu    = "200m"
              memory = "100Mi"
            }
          }

          env {
            name  = "WORDPRESS_DB_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.cloudsql-creds.metadata[0].name
                key  = "db_ip"
              }
            }
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.cloudsql-creds.metadata[0].name
                key  = "db_passwd"
              }
            }
          }
          env {
            name = "WORDPRESS_DB_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.cloudsql-creds.metadata[0].name
                key  = "db_user"
              }
            }
          }
          port {
            container_port = 80
            name           = "wordpress"
          }

          volume_mount {
            name       = "wordpress-persistent-storage"
            mount_path = "/var/www/html"
          }
        }

        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wordpress.metadata[0].name
          }
        }
      }
    }
  }
}

# resource "kubernetes_storage_class" "pd-ssd" {
#   metadata {
#     name = "pd-ssd"
#   }

#   storage_provisioner = "kubernetes.io/gce-pd"

#   parameters = {
#     type = "pd-ssd"
#   }
# }

# resource "google_compute_disk" "wordpress" {
#   project = var.project_id
#   name = "wordpress-frontend"
#   type = "pd-ssd"
#   zone = "${var.region}-${var.zone}"
#   size = 20
# }

# resource "kubernetes_persistent_volume" "wordpress" {
#   metadata {
#     name = "wordpress-pv"
#   }
#   spec {
#     capacity = {
#       storage = "20Gi"
#     }
#     # storageClassName = "standard"
#     access_modes = ["ReadWriteOnce"]
#     persistent_volume_source {
#       gce_persistent_disk {
#         pd_name = google_compute_disk.wordpress.name
#         fs_type = "ext4"
#       }
#     }
#   }
# }

