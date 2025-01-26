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

# resource "docker_volume" "database" {
#   name = "database"
# }

# resource "docker_volume" "redis" {
#   name = "redis"
# }

# resource "docker_container" "postgresql" {
#   image = "docker.io/library/postgres:16-alpine"
#   name  = "postgresql"
#   restart = "unless-stopped"

#   env = [
#     "POSTGRES_PASSWORD=${var.pg_pass}",
#     "POSTGRES_USER=${var.pg_user}",
#     "POSTGRES_DB=${var.pg_db}"
#   ]

#   volumes {
#     volume_name    = docker_volume.database.name
#     container_path = "/var/lib/postgresql/data"
#   }

#   networks_advanced {
#     name = var.network_name
#   }

#   healthcheck {
#     test         = ["CMD-SHELL", "pg_isready -d ${var.pg_db} -U ${var.pg_user}"]
#     start_period = "20s"
#     interval     = "30s"
#     retries      = 5
#     timeout      = "5s"
#   }
# }

# resource "docker_container" "redis" {
#   image = "docker.io/library/redis:alpine"
#   name  = "redis"
#   restart = "unless-stopped"
#   command = ["--save", "60", "1", "--loglevel", "warning"]

#   volumes {
#     volume_name    = docker_volume.redis.name
#     container_path = "/data"
#   }

#   networks_advanced {
#     name = var.network_name
#   }

#   healthcheck {
#     test         = ["CMD-SHELL", "redis-cli ping | grep PONG"]
#     start_period = "20s"
#     interval     = "30s"
#     retries      = 5
#     timeout      = "3s"
#   }
# }

# resource "docker_container" "authentik_server" {
#   image   = "beryju/authentik:2024.12"
#   name    = "authentik_server"
#   restart = "unless-stopped"
#   command = ["server"]

#   env = [
#     "AUTHENTIK_REDIS__HOST=redis",
#     "AUTHENTIK_POSTGRESQL__HOST=postgresql",
#     "AUTHENTIK_POSTGRESQL__USER=${var.pg_user}",
#     "AUTHENTIK_POSTGRESQL__NAME=${var.pg_db}",
#     "AUTHENTIK_POSTGRESQL__PASSWORD=${var.pg_pass}",
#     "AUTHENTIK_SECRET_KEY=${var.secret_key}",
#   ]

#   networks_advanced {
#     name = var.network_name
#   }

#   volumes {
#     host_path      = "${abspath(path.module)}/media"
#     container_path = "/media"
#   }

#   volumes {
#     host_path      = "${abspath(path.module)}/custom-templates"
#     container_path = "/templates"
#   }

#   ports {
#     internal = 9000
#     external = var.compose_port_http
#   }

#   ports {
#     internal = 9443
#     external = var.compose_port_https
#   }

#   depends_on = [
#     docker_container.postgresql,
#     docker_container.redis
#   ]
# }

# resource "docker_container" "authentik_worker" {
#   image   = "beryju/authentik:2024.12"
#   name    = "authentik_worker"
#   restart = "unless-stopped"
#   command = ["worker"]

#   env = [
#     "AUTHENTIK_REDIS__HOST=redis",
#     "AUTHENTIK_POSTGRESQL__HOST=postgresql",
#     "AUTHENTIK_POSTGRESQL__USER=${var.pg_user}",
#     "AUTHENTIK_POSTGRESQL__NAME=${var.pg_db}",
#     "AUTHENTIK_POSTGRESQL__PASSWORD=${var.pg_pass}",
#     "AUTHENTIK_SECRET_KEY=${var.secret_key}"
#   ]

#   networks_advanced {
#     name = var.network_name
#   }
  
#   user = "root"

#   volumes {
#     host_path      = "/var/run/docker.sock"
#     container_path = "/var/run/docker.sock"
#   }

#   volumes {
#     host_path      = "${abspath(path.module)}/media"
#     container_path = "/media"
#   }

#   volumes {
#     host_path      = "${abspath(path.module)}/certs"
#     container_path = "/certs"
#   }

#   volumes {
#     host_path      = "${abspath(path.module)}/custom-templates"
#     container_path = "/templates"
#   }

#   depends_on = [
#     docker_container.postgresql,
#     docker_container.redis
#   ]
# }