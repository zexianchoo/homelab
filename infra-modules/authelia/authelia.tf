terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "authelia" {
  name = "authelia/authelia:latest"
}

resource "docker_image" "redis_image" {
  name = "docker.io/library/redis:alpine"
}

resource "docker_image" "postgres_image" {
  name = "docker.io/library/postgres:18-alpine"
}

resource "docker_volume" "database" {
  name = "database"
}

resource "docker_volume" "redis" {
  name = "redis"
}

resource "docker_container" "redis" {
  image = docker_image.redis_image.image_id
  name  = "authelia_redis"
  restart = "unless-stopped"
  command = ["--save", "60", "1", "--loglevel", "warning"]

  volumes {
    volume_name    = docker_volume.redis.name
    container_path = "/data"
  }
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test         = ["CMD-SHELL", "redis-cli ping | grep PONG"]
    start_period = "20s"
    interval     = "30s"
    retries      = 5
    timeout      = "3s"
  }
}

resource "docker_container" "postgresql" {
  image = docker_image.postgres_image.image_id
  name  = "postgresql"
  restart = "unless-stopped"

  env = [
    "POSTGRES_PASSWORD=${var.pg_pass}",
    "POSTGRES_USER=${var.pg_user}",
    "POSTGRES_DB=${var.pg_db}"
  ]

  volumes {
    volume_name    = docker_volume.database.name
    container_path = "/var/lib/postgresql/data"
  }
  network_mode = "bridge"
  ports {
    internal = 5432
    external = 5432
  }

  networks_advanced {
    name = var.network_name
  }

  healthcheck {
    test         = ["CMD-SHELL", "pg_isready -d ${var.pg_db} -U ${var.pg_user}"]
    start_period = "20s"
    interval     = "30s"
    retries      = 5
    timeout      = "5s"
  }
}

resource "docker_container" "authelia" {
  name  = "authelia"
  image = docker_image.authelia.image_id

  restart = "unless-stopped"

  ports {
    internal = 9091
    external = 9091
  }
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path      = "${var.volume_path}/authelia/config"
    container_path = "/config"
  }

  depends_on = [
    docker_container.redis,
    docker_container.postgresql
  ]

}
