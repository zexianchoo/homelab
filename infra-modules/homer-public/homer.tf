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

resource "docker_image" "homer-public" {
  name = "b4bz/homer"
}

resource "docker_container" "homer-public" {
  name  = "homer-public"
  image = docker_image.homer-public.image_id

  restart = "unless-stopped"
  network_mode = "bridge"

  networks_advanced {
    name = var.network_name
  }

  env = [
    "PORT=8081",
  ]

  ports {
    internal = 8081
    external = 8081
  }

  healthcheck {
    test     = ["CMD", "wget", "-qO-", "http://localhost:8081"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }

  volumes {
    host_path = "${var.volume_path}/homer-public/config"
    container_path = "/www/assets"
  }    
}
