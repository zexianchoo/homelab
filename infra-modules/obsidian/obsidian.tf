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

data "docker_registry_image" "obsidian_db" {
  name = "couchdb:latest"
}

resource "docker_image" "obsidian_db" {
  name          = data.docker_registry_image.obsidian_db.name
  pull_triggers = [data.docker_registry_image.obsidian_db.sha256_digest]
}

resource "docker_container" "obsidian_db" {
  name  = "obsidian_db"
  image = docker_image.obsidian_db.image_id

  restart = "unless-stopped"
  ports {
    internal = 5984
    external = 5984
  }

  env = [
    "PUID=99",
    "PGID=100",
    "UMASK=0022",
    "TZ=America/New_York",
    "COUCHDB_USER=${var.OBSIDIAN_COUCHDB_USER}",
    "COUCHDB_PASSWORD=${var.OBSIDIAN_COUCHDB_PASS}",
  ]    


  network_mode = "bridge"
  networks_advanced {
    name = var.network_name
  }

  volumes {
    host_path      = "${var.volume_path}/couchdb/configs/custom.ini"
    container_path = "/opt/couchdb/etc/local.d/custom.ini"
  }

}
