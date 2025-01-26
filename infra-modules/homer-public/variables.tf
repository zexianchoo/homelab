variable "network_name" {
  description = "Homelab network name"
  type        = string
}

variable "volume_path" {
  description = "Path to bind mounts of docker containers"
  type        = string
}
