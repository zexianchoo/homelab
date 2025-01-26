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

resource "docker_image" "watchtower" {
  name = "containrrr/watchtower"
}

resource "docker_container" "watchtower" {
  name  = "watchtower"
  image = docker_image.watchtower.image_id
  network_mode = "bridge"
  restart = "unless-stopped"

  volumes {
    host_path = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }    
}
