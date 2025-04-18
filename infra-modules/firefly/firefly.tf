terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly/.env")) : tuple[0] => sensitive(tuple[1]) }
  db_envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly/.db.env")) : tuple[0] => sensitive(tuple[1]) }
  importer_envs = { for tuple in regexall("(.*)=(.*)", file("${var.module_path}/firefly/.importer.env")) : tuple[0] => sensitive(tuple[1]) }
}
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "docker_registry_image" "firefly" {
  name = "fireflyiii/core:latest"
}

resource "docker_image" "firefly" {
  name          = data.docker_registry_image.firefly.name
  pull_triggers = [data.docker_registry_image.firefly.sha256_digest]
}


resource "docker_container" "firefly" {
  name  = "firefly"
  image = docker_image.firefly.image_id
  env   = [for key, value in local.envs : "${key}=${value}"]

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8080
    external = 12321
  }

  restart = "unless-stopped"
  network_mode = "bridge"

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:8080"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    host_path      = "${var.volume_path}/firefly/upload"
    container_path = "/var/www/html/storage/upload"
  }
  depends_on = [docker_container.firefly_db]
}

data "docker_registry_image" "firefly_db" {
  name = "public.ecr.aws/docker/library/mariadb:latest"
  # name = "mariadb:latest"
}

resource "docker_image" "firefly_db" {
  name          = data.docker_registry_image.firefly_db.name
  pull_triggers = [data.docker_registry_image.firefly_db.sha256_digest]
}

resource "docker_container" "firefly_db" {
  name         = "firefly_db"
  image        = docker_image.firefly_db.image_id
  hostname     = "db"
  restart      = "always"
  network_mode = "bridge"
  # user = "root"
  networks_advanced {
    name = var.network_name
  }
  volumes {
    host_path      = "${var.volume_path}/firefly/db"
    container_path = "/var/lib/mysql"
  }
  env   = [for key, value in local.db_envs : "${key}=${value}"]
}

resource "docker_image" "firefly_importer" {
  name = "fireflyiii/data-importer:latest"
}

resource "docker_container" "firefly_importer" {
  name  = "firefly_importer"
  image = docker_image.firefly_importer.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  env = [
    for key, value in local.importer_envs : "${key}=${value}"
  ]

  ports {
    internal = 8080
    external = 10100
  }

}

