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

variable "firefly_random_root_password" {
  description = "module parent dir path"
  type        = string
}

variable "firefly_mysql_user" {
  description = "module parent dir path"
  type        = string
}

variable "firefly_mysql_password" {
  description = "module parent dir path"
  type        = string
}

variable "firefly_mysql_database" {
  description = "module parent dir path"
  type        = string
}
