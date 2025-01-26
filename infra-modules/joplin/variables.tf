variable "network_name" {
  description = "Homelab network name"
  type        = string
}

variable "domain_name" {
  description = "domain_name"
  type        = string
}

variable "volume_path" {
  description = "Path to bind mounts of docker containers"
  type        = string
}

variable "joplin_db_password" {
  description = "pass of the jopline' mariadb"
  type        = string
}

variable "joplin_db_root_password" {
  description = "pass of the jopline' mariadb"
  type        = string
}

variable "joplin_db_database" {
  description = "dbname of the jopline' mariadb"
  type        = string
}

variable "joplin_db_user" {
  description = "user of the jopline' mariadb"
  type        = string
}
