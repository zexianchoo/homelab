variable "network_name" {
  description = "Homelab network name"
  type        = string
}

variable "domain_name" {
  description = "root domain name"
  type        = string
}

variable "volume_path" {
  description = "Path to bind mounts of docker containers"
  type        = string
}

variable "OBSIDIAN_COUCHDB_USER" {
  type        = string
}

variable "OBSIDIAN_COUCHDB_PASS" {
  type        = string
}
