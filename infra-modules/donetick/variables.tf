variable "network_name" {
  description = "Homelab network name"
  type        = string
}

variable "domain_name" {
  description = "domain_name"
  type        = string
}

variable "module_path" {
  description = "module_path"
  type        = string
}

variable "volume_path" {
  description = "Path to bind mounts of docker containers"
  type        = string
}

