provider "google" {
  version = "~> 3.5"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

resource "random_id" "name" {
  byte_length = 2
}

resource "random_id" "instance_name_suffix" {
  byte_length = 5
}

locals {
  /*
    Random instance name needed because:
    "You cannot reuse an instance name for up to a week after you have deleted an instance."
    See https://cloud.google.com/sql/docs/mysql/delete-instance for details.
  */
  instance_name = "${var.db_name}-${random_id.instance_name_suffix.hex}"
}

resource "google_sql_database_instance" "default" {
  project          = var.project_id
  name             = local.instance_name
  database_version = var.database_version
  region           = var.region
  settings {
    tier              = var.tier
    ip_configuration {
      ipv4_enabled    = true
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        iterator = cidr

        content {
          name  = "cidr-${cidr.key}"
          value = cidr.value
        }
      }
    }
  }
}

resource "google_sql_database" "default" {
  name       = var.db_name
  project    = var.project_id
  instance   = google_sql_database_instance.default.name
  depends_on = [google_sql_database_instance.default]
}

resource "random_id" "user-password" {
  keepers = {
    name = google_sql_database_instance.default.name
  }

  byte_length = 8
  depends_on  = [google_sql_database_instance.default]
}

resource "google_sql_user" "default" {
  name       = var.user_name
  project    = var.project_id
  instance   = google_sql_database_instance.default.name
  host       = var.user_host
  password   = var.user_password == "" ? random_id.user-password.hex : var.user_password
  depends_on = [google_sql_database_instance.default]
}


resource "kubernetes_secret" "cloudsql-creds" {
  metadata {
    name = "cloudsql-creds"
  }

  data = {
    db_user = var.user_name
    db_passwd = var.user_password
    db_ip  = google_sql_database_instance.default.ip_address.0.ip_address
  }
}