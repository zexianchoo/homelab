terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/immich/.env")) : tuple[0] => sensitive(tuple[1]) }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "immich_server" {
  name = "ghcr.io/immich-app/immich-server:release"
}



resource "docker_container" "immich_server" {
  name  = "immich_server"
  image = docker_image.immich_server.image_id
  volumes {
    # host_path = "${var.volume_path}/immich/library"
    host_path = "/mnt/windows/Users/kai10/Desktop/Photos/library"
    container_path = "/usr/src/app/upload"
  }
#   volumes {
#     container_path = "/usr/src/app/upload"
#     read_only = true
#   }
  volumes {
    volume_name    = "/etc/localtime"
    container_path = "/etc/localtime"
    read_only      = true
  }

  env = [for key, value in local.envs : "${key}=${value}"]
  ports {
    internal = 2283
    external = 2283
  }
  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }
  restart = "unless-stopped"
  depends_on = [docker_container.immich_redis, docker_container.immich_db]
}

resource "docker_image" "immich_machine_learning" {
  name = "ghcr.io/immich-app/immich-machine-learning:release"
}

resource "docker_container" "immich_machine_learning" {
  name  = "immich_machine_learning"
  image = docker_image.immich_machine_learning.image_id
  volumes {
    volume_name    = "model-cache"
    container_path = "/cache"
  }
  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }
  env = [for key, value in local.envs : "${key}=${value}"]
  restart = "unless-stopped"
}

resource "docker_image" "immich_redis" {
  name = "docker.io/redis:6.2-alpine@sha256:905c4ee67b8e0aa955331960d2aa745781e6bd89afc44a8584bfd13bc890f0ae"
}

resource "docker_container" "immich_redis" {
  name  = "immich_redis"
  image = docker_image.immich_redis.image_id
  restart = "unless-stopped"
  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }
}

resource "docker_image" "immich_db" {
  name = "docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0"
}

resource "docker_container" "immich_db" {
  name  = "immich_postgres"
  image = docker_image.immich_db.image_id
  env = [
    "POSTGRES_PASSWORD=${var.immich_db_pass}",
    "POSTGRES_USER=${var.immich_db_user}",
    "POSTGRES_DB=${var.immich_db_name}",
    "POSTGRES_INITDB_ARGS=--data-checksums"
  ]
  volumes {
    volume_name    = "${var.volume_path}/immich/data"
    container_path = "/var/lib/postgresql/data"
  }
  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }
  restart = "unless-stopped"
}
