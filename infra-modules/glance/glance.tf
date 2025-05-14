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
  registry_auth {
    address   = "registry-1.docker.io"
    username  = var.dockerhub_user
    password  = var.dockerhub_pass
  }
}

data "docker_registry_image" "glance" {
  name = "glanceapp/glance"
}

resource "docker_image" "glance" {
  name          = data.docker_registry_image.glance.name
  pull_triggers = [data.docker_registry_image.glance.sha256_digest]
}

resource "docker_container" "glance" {
  name  = "glance"
  image = docker_image.glance.image_id
  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=America/Chicago"
  ]

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8080
    external = 8080
  }

  restart = "unless-stopped"
  network_mode = "bridge"

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://glance:8080"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
  
  volumes {
    host_path = "${var.volume_path}/glance/config"
    container_path = "/app/config"
  }  

  volumes {
    host_path = "/etc/localtime"
    container_path = "/etc/localtime"
  }  

  volumes {
    host_path = "/etc/timezone"
    container_path = "/etc/timezone"
  }  
}
