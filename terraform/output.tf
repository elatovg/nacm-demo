output "project_id" {
  value       = var.project_id
  description = "The project to run tests against"
}

output "name" {
  value       = local.instance_name
  description = "The name for Cloud SQL instance"
}

output "mysql_conn" {
  value       = google_sql_database_instance.default.connection_name
  description = "The connection name of the master instance to be used in connection strings"
}


output "public_ip_address" {
  description = "The first public (PRIMARY) IPv4 address assigned for the master instance"
  value       = google_sql_database_instance.default.ip_address.0.ip_address
}

output "lb_ip" {
  value = kubernetes_service.wordpress.load_balancer_ingress[0].ip
}