# terraform {
#   required_providers {
#     docker = {
#       source  = "kreuzwerker/docker"
#       version = "~> 3.0"
#     }
#   }
# }

# provider "docker" {
#   host = "unix:///var/run/docker.sock"
# }

# resource "docker_image" "bitwarden" {
#   name = "bitwarden/server"
# }

# resource "docker_container" "bitwarden" {
#   name  = "bitwarden"
#   image = docker_image.bitwarden.image_id

#   restart = "unless-stopped"
#   # network_mode = "bridge"

#   networks_advanced {
#     name = var.network_nameur
#   }

#   env = [
#     "PORT=8081",
#   ]

#   ports {
#     internal = 8081
#     external = 8081
#   }

#   healthcheck {
#     test     = ["CMD", "wget", "-qO-", "http://bitwarden:8081"]
#     interval = "30s"
#     timeout  = "10s"
#     retries  = 3
#   }

#   volumes {
#     host_path = "${var.volume_path}/bitwarden/config"
#     container_path = "/www/assets"
#   }    
# }
