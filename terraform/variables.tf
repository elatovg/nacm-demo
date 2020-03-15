variable "project_id" {
  description = "The ID of the project in which resources will be provisioned."
  type        = string
  default     = "elatov-demo"
}

variable "instance_name" {
  description = "The name of the SQL Database instance"
  default     = "cloudsql"
}

variable "db_name" {
  description = "The name of the SQL Database"
  default     = "wp"
}

// required
variable "database_version" {
  description = "The database version to use"
  type        = string
  default     = "MYSQL_5_7"
}

// required
variable "region" {
  description = "The region of the Cloud SQL resources"
  type        = string
  default     = "us-east4"
}

variable "zone" {
  description = "The zone for the master instance (ie `a`, `c`.)"
  type        = string
  default     = "c"
}

variable "tier" {
  description = "The tier for the master instance."
  type        = string
  default     = "db-f1-micro"
}

variable "user_name" {
  description = "Username for DB Access"
  type        = string
  default     = "wordpress"
}

variable "user_host" {
  description = "Userhost for DB Access"
  type        = string
  default     = "%"
}

variable "user_password" {
  description = "user password for DB Access"
  type        = string
  default     = "change-me"
}


variable "wordpress_version" {
  description = "wordpress version"
  type        = string
  default     = "5.2.2"
}

variable "authorized_networks" {
  default = ["208.0.0.0/8", "199.0.0.0/8", "192.0.0.0/8","173.0.0.0/8", "162.0.0.0/8", "146.0.0.0/8", "130.0.0.0/8", "108.0.0.0/8", "107.0.0.0/8", "104.0.0.0/8", "35.0.0.0/8", "34.0.0.0/8", "23.0.0.0/8", "8.0.0.0/8"]
  type        = list(string)
  description = "List of mapped public networks authorized to access to the instances. Default - short range of GCP health-checkers IPs"
}